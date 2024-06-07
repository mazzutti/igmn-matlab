using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;

using InterfaceSRP;
using ModelSRP;
using static ModelSRP.PetrelObjectWrapper;
using static ModelSRP.IGMNInversionModel;

using Slb.Ocean.Petrel;
using Slb.Ocean.Core;
using Slb.Ocean.Petrel.DomainObject;
using Slb.Ocean.Petrel.DomainObject.Well;
using Slb.Ocean.Petrel.DomainObject.Seismic;

//The controller class only handles logic within the structures known by the model

namespace ControllerSRP
{
    public class IGMNInversionController
    {
        //Lists containing all the wells/zones the user can select
        readonly List<SelectableItem> wells;
        readonly List<SelectableItem> zones;

        //Dynamic list that contains pairs with the selected zones and the selected wells (as long as the zone exists for that well)
        List<WellZoneItemPair> wellZones;

        //Seismic cubes selected by the user
        readonly Dictionary<int, InputSeismicCube> inputCubes;

        //Output cube name/properties selected by the user
        readonly List<OutputSeismicCube> outputCubes;

        //All known log types (extracted from the global well logs)
        HashSet<WellLogInfo> wellLogTypes;

        //Reciprocal of the amount of cells (defined by the user through the view)
        float gridSize = 0.0f;

        //Arbitrary line that will be used to restrict data processing (if any)
        SeismicLine3D currentLine = null;

        //Reference to the view used on initialization
        readonly IGMNInversionWindow view;

        public IGMNInversionController(IGMNInversionWindow view)
        {
            this.view = view;

            wells = GetProjectWells();
            zones = GetProjectZones();
            //Define the actions for the interface elements
            view.RunIGMNInversion = this.RunIGMNInversion;

            view.ReadWellList = this.ReadWellList;
            view.ReadZoneList = this.ReadZoneList;
            view.ReadWellsCrossZones = this.ReadWellsCrossZones;
            view.ReadWellLogTypes = this.ReadWellLogTypes;

            view.FlipWellSelection = this.FlipWellSelection;
            view.FlipZoneSelection = this.FlipZoneSelection;

            view.InterpretCubeInput = this.InterpretCubeInput;
            view.InterpretRandomLineInput = this.InterpretRandomLineInput;

            view.UpdateOutputCube = this.UpdateOutputCube;
            view.UpdateGridSize = this.UpdateGridSize;

            view.DeleteInputRow = this.DeleteInputRow;
            view.DeleteOutputRow = this.DeleteOutputRow;

            inputCubes = new Dictionary<int, InputSeismicCube>();
            outputCubes = new List<OutputSeismicCube>();
            wellZones = new List<WellZoneItemPair>();
        }

        #region Implementation of Actions that will be used by the interface

        public void RunIGMNInversion(string folderName)
        {
            try
            {
                //IMPORTANT: The shape of dCond is NxIxJxK, where N is the amount of input properties
                //This is different from what the original algorithm uses (MxN, where M is the total amount of points)
                //Reshaping the variables at this point would require moving high amounts of memory
                IGMNInversionInput inputResults = GenerateInputArrays();
                IGMNInversionOutput outputResults = null;

                IGMNInversionCLI cppEngine = null;
                IProgress progressBar = null;
                BatchExecutor algorithmExecutor = null;
                BatchExecutor mainExecutor = null;

                mainExecutor = new BatchExecutor(
                    new Action[] {
                        // Block window
                        () => view.EnableWindow(false),
                        // Run
                        () => algorithmExecutor?.ParallelStart(),
                        () => algorithmExecutor?.WaitTasks(),
                        // Clean Up
                        () => System.Windows.Application.Current.Dispatcher.Invoke(() => {
                            cppEngine?.Dispose();
                            progressBar?.Dispose();
                        }),
                        // Save
                        () => { if (!mainExecutor.HadExceptions) SaveOutputData(folderName, outputResults); },
                        // Unblock window
                        () => view.EnableWindow(true)
                    }, null);

                    outputResults = new IGMNInversionOutput(inputResults.mTrain.GetLength(1),
                        inputResults.dCond[0].GetLength(0), inputResults.dCond[0].GetLength(1), inputResults.dCond[0].GetLength(2));
                    cppEngine = new IGMNInversionCLI(ref inputResults.dTrain, ref inputResults.mTrain, inputResults.gridSize);
                    cppEngine.SetSeismicCubeData(ref inputResults.dCond, ref outputResults.outCubes);
                    cppEngine.PrepareTrainingData();

                    if (currentLine == null)
                    {
                        int maximumThreads = 8;
                        var execSegments = new List<Action>();
                        var progressSegments = new List<Ref<int>>();

                        foreach (var seg in SegmentRange(inputResults.dCond[0].Length, maximumThreads))
                        {
                            var (index, lowerBound, upperBound) = seg;
                            progressSegments.Add(new Ref<int>(0));
                            execSegments.Add(() => cppEngine.RunIGMNInversionCLI(lowerBound, upperBound, ref progressSegments[index].value));
                        }

                        progressBar = PetrelLogger.NewProgress(0, inputResults.dCond[0].Length);
                        progressBar.SetProgressText("Generating Output Cubes");

                        algorithmExecutor = new BatchExecutor(execSegments,
                            () => progressBar.ProgressStatus = progressSegments.Select(x => x.value).Sum());

                        mainExecutor.SequentialStart(false);
                    }
                    else
                    {
                        algorithmExecutor = new BatchExecutor(() => cppEngine.RunIGMNInversionCLI(), null);
                        mainExecutor.SequentialStart(false);
                        mainExecutor.WaitTasks();
                    }
            }
            catch (Exception e)
            {
                PetrelLogger.InfoOutputWindow(e.ToString());
                MessageBox.Show("Something went wrong...\n\n" + e.ToString(), "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            return;
        }

        public List<Tuple<bool, string>> ReadWellList()
        {
            return wells.Select(x => Tuple.Create(x.selected, ((Borehole)x.item).Name)).ToList();
        }

        public List<Tuple<bool, string>> ReadZoneList()
        {
            return zones.Select(x => Tuple.Create(x.selected, ((Zone)x.item).Name)).ToList();
        }

        public List<string> ReadWellsCrossZones()
        {
            List<string> ret = new List<string>();

            GenerateWellsCrossZones();

            foreach (var wellZone in wellZones)
            {
                ret.Add(wellZone.boreholeZone.Zone.Name + " (" + wellZone.well.Name + ")");
            }

            return ret;
        }

        public List<string> ReadWellLogTypes()
        {
            List<string> ret = new List<string>();

            //TO DO: Remove this validation for the release
            try { var x = PetrelProject.PrimaryProject; } catch {
                wellLogTypes = new HashSet<WellLogInfo>
                {
                    null
                }; ret.Add("Empty"); return ret; }

            wellLogTypes = WellRoot.Get(PetrelProject.PrimaryProject).
                AllWellLogVersions.Select(x => new WellLogInfo(x, x.Template)).GroupBy(x => x.template).Select(g => g.First()).ToHashSet();

            return wellLogTypes.Select(x => x.template.Name).ToList();
        }

        public bool FlipWellSelection(int index)
        {
            wells[index].selected = !wells[index].selected;
            return wells[index].selected;
        }
        public bool FlipZoneSelection(int index)
        {
            zones[index].selected = !zones[index].selected;
            return zones[index].selected;
        }

        public Tuple<int, string, string> InterpretCubeInput(object sender, DragEventArgs e)
        {
            SeismicCube cube = e.Data.GetData(typeof(object)) as SeismicCube;

            if (cube == null) return Tuple.Create(-1, "", "");

            InputSeismicCube newCube = new InputSeismicCube
            {
                pCube = cube,
                wellLog = null //RESERVED (binds the cube to a specific well log)
            };

            //Notice that the same cube can be added multiple times because the user might select a different log for the same cube later on
            //The dictionay key is used only to provide access to this element through the interface
            int cubeID = (inputCubes.Count > 0) ? (inputCubes.Keys.Max() + 1) : 0;
            inputCubes.Add(cubeID, newCube);

            //The interface will store the ID and display the name of the cube and its type
            return Tuple.Create(cubeID, cube.Name, cube.Template.Name);
        }

        public string InterpretRandomLineInput(object sender, DragEventArgs e) {
            SeismicLine3D randomLine = e?.Data.GetData(typeof(object)) as SeismicLine3D;
            if (randomLine != null) {
                currentLine = randomLine;
            } else if (e == null) {
                currentLine = null;
            }
            return (currentLine == null) ? null :
                currentLine.Name + ((currentLine.SeismicCube != null) ? " (from " + currentLine.SeismicCube.Name + ")" : "");
        }

        public void UpdateOutputCube(int cubeID, string newCubeName, int propertyIndex)
        {
            OutputSeismicCube editCube;
            if (cubeID >= outputCubes.Count)
            {
                //It's a new output row
                editCube = new OutputSeismicCube();
                outputCubes.Add(editCube);
            }
            else
            {
                //It's an existing row
                editCube = outputCubes.ElementAt(cubeID);
            }

            editCube.cubeName = newCubeName;
            editCube.logType = wellLogTypes.ElementAt(propertyIndex);

        }
        public void UpdateGridSize(float newGridSize)
        {
            gridSize = newGridSize;
        }

        public void DeleteInputRow(int cubeID)
        {
            inputCubes.Remove(cubeID);
        }

        public void DeleteOutputRow(int rowIndex)
        {
            outputCubes.RemoveAt(rowIndex);
        }
        #endregion

        /// <summary>Creates the plugin's main folder if necessary then creates or returns an existing folder with a given name under it.</summary>
        public static SeismicCollection PrepareOutputFolder(string folderName, bool is2D)
        {
            SeismicCollection sCollecionOut = null;
            using (ITransaction tr = DataManager.NewTransaction())
            {
                var seismicProject = SeismicRoot.Get(PetrelProject.PrimaryProject).SeismicProject;
                tr.Lock(seismicProject);

                var mainCollecion = CreateOrReplaceFolder("IGMN Rock Physics" + (is2D?" 2D":""), seismicProject);
                tr.Lock(mainCollecion);
                sCollecionOut = CreateOrReplaceFolder(folderName, mainCollecion);
            }
            return sCollecionOut;
        }

        public void SaveOutputData(string folderName, IGMNInversionOutput outputResults)
        {
            System.Windows.Application.Current.Dispatcher.Invoke(() => {
                var outputFolder = PrepareOutputFolder(folderName, (currentLine != null));

                if (currentLine == null)
                {
                    for (int i = 0; i < outputCubes.Count; i++)
                    {
                        SetColorTable(
                            WriteCube(outputFolder, inputCubes.ElementAt(0).Value.pCube, outputResults.outCubes[i], outputCubes[i].cubeName, outputCubes[i].logType.template),
                            outputCubes[i].logType.refereceObject);
                    }
                    MessageBox.Show("Output Seismic Cubes saved!", "Execution Finished", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                else
                {
                    for (int i = 0; i < outputCubes.Count; i++)
                    {
                        SetColorTable(
                        WriteSeismic2D(outputFolder, currentLine, inputCubes.ElementAt(0).Value.pCube, outputResults.outCubes[i], outputCubes[i].cubeName, outputCubes[i].logType.template),
                            outputCubes[i].logType.refereceObject);
                    }
                    MessageBox.Show("Output Seismic Lines saved!", "Execution Finished", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            });
        }

        private IEnumerable<(int index, ulong lowerBound, ulong upperBound)> SegmentRange(int maximumValue, int segmentAmount)
        {
            for (int i = 0; i < segmentAmount; ++i)
            {
                ulong upperBound = (ulong)((i + 1) * maximumValue) / (ulong)segmentAmount;
                ulong lowerBound = (ulong)(i * maximumValue) / (ulong)segmentAmount;
                if (lowerBound > 0) lowerBound++;
                yield return (i, lowerBound, upperBound);
            }
        }

        /// <summary>Lists all valid well+boreholezone pairs for the current wells and zones.</summary>
        public void GenerateWellsCrossZones()
        {
            wellZones = new List<WellZoneItemPair>();

            //Create two dictionaries using only the selected wells and zones
            Dictionary<Object, SelectableItem> selectedWells = new Dictionary<Object, SelectableItem>();
            Dictionary<Object, SelectableItem> selectedZones = new Dictionary<Object, SelectableItem>();

            foreach (var wItem in wells)
            {
                if (wItem.selected) selectedWells.Add(wItem.item, wItem);
            }

            foreach (var zItem in zones)
            {
                if (zItem.selected) selectedZones.Add(zItem.item, zItem);
            }

            //TO DO: Remove this validation for the release
            try { var x = PetrelProject.PrimaryProject; } catch { return; }

            var projMarkers = WellRoot.Get(PetrelProject.PrimaryProject).MarkerCollections;

            //Check every borehole that was selected
            foreach (var selectedWell in selectedWells)
            {
                Borehole borehole = selectedWell.Value.item as Borehole;
                if (borehole != null)
                {
                    //Check every marker collection to see if it has zones for this well
                    foreach (var markerCollection in projMarkers)
                    {
                        var boreholeZones = markerCollection.GetBoreholeZones(borehole);
                        //For each zone found, check if it was selected
                        foreach (var bZone in boreholeZones)
                        {
                            if (selectedZones.ContainsKey(bZone.Zone))
                            {
                                WellZoneItemPair newWZPair = new WellZoneItemPair
                                {
                                    well = borehole,
                                    boreholeZone = bZone
                                };
                                wellZones.Add(newWZPair);
                            }
                        }
                    }
                }
            }
        }

        /// <summary>Generates the input arrays (dTrain, mTrain and dCond) for the main algorithm.</summary>
        public IGMNInversionInput GenerateInputArrays()
        {
            var ret = new IGMNInversionInput();

            //Prepare the output structures
            int dTrainVars = inputCubes.Count;
            int mTrainVars = outputCubes.Count;
            int logAmount = dTrainVars + mTrainVars;
            ret.dCond = new float[dTrainVars][,,];
            List<float>[] logSamples = new List<float>[logAmount];
            for (int i = 0; i < logAmount; i++) logSamples[i] = new List<float>();

            //Read all input cubes, convert them into arrays and read the log types for dTrain
            var wantedLogs = new Template[logAmount];
            int propertyIndex = 0;
            foreach (var cube in inputCubes)
            {
                ret.dCond[propertyIndex] = (currentLine == null) ? ReadCube(cube.Value.pCube) : ReadTraceView(cube.Value.pCube, currentLine);
                wantedLogs[propertyIndex] = cube.Value.pCube.Template;
                propertyIndex++;
            }
            //Read the log types for mTrain
            foreach (var cube in outputCubes)
            {
                wantedLogs[propertyIndex] = cube.logType.template;
                propertyIndex++;
            }

            //Extract samples from each region
            Borehole currentWell = null;
            WellLog[] selectedLogs = null;
            foreach (var wellZone in wellZones)
            {
                //Check if a new well is starting. WellZones is generated one well at a time, they are guaranteed to be grouped
                if (currentWell != wellZone.well)
                {
                    currentWell = wellZone.well;

                    //Find the logs of the wanted types in the current well
                    selectedLogs = new WellLog[logAmount];
                    int sLogIndex = 0;
                    //Check each wanted log (the order here is important)
                    foreach (var wLog in wantedLogs)
                    {
                        //For this well, is there any log of the wanted type?
                        var candidates = currentWell.Logs.AllWellLogVersions.Where(m => m.Template == wLog).ToList();

                        //There should be only one log of the wanted type. If there are more, we'll pick the first
                        if (candidates.Count >= 1) {
                            selectedLogs[sLogIndex] = currentWell.Logs.GetWellLog(candidates.ElementAt(0));
                        } else {
                            //TO DO: warning in case no candidates are found
                            selectedLogs[0] = null;
                            break;
                        }
                        sLogIndex++;
                    }
                }

                //If the first selectedLog is marked as null, it means at least one log doesn't exist for this well
                //Since all logs are needed for each row, no data will be read for this well
                if (selectedLogs[0] != null) {
                    //Get the samples for each region in the current well
                    //Notice this assumes every log type has the same amount of samples at the same depths
                    int logIndex = 0;
                    foreach (var log in selectedLogs) {
                        var sampledValues = log.Samples
                            .Where(x =>
                                ((x.MD >= wellZone.boreholeZone.StartMarker.MD)
                                && (x.MD <= wellZone.boreholeZone.EndMarker.MD)))
                                    .Select(y => (float)y.Value).ToArray();
                        logSamples[logIndex].AddRange(sampledValues);
                        logIndex++;
                    }
                }
            }

            //Count valid rows (the output needs a fixed size)
            //Some rows might have NaN values, those shouldn't be included in the final array
            //Therefore, just checking the list sizes wouldn't suffice
            //Iterate using logSamples[0] because the lists on every index should be the same size
            int totalRows = 0;
            for (int i = 0; i < logSamples[0].Count; i++)
            {
                //Test if there is a NaN value in this row
                int nanIndex = 0;
                while (nanIndex < logAmount) {
                    if (float.IsNaN(logSamples[nanIndex][i])) break;
                    nanIndex++;
                }
                if (nanIndex == logAmount) {
                    //No NaN values found, this entire row is valid
                    totalRows++;
                } else {
                    //Failed a test, mark the first value as NaN so that it can be checked with one comparison next time
                    logSamples[0][i] = Single.NaN;
                }
            }

            //Initialize the output arrays
            ret.dTrain = new float[totalRows, dTrainVars];
            ret.mTrain = new float[totalRows, mTrainVars];
            totalRows = 0;

            //Fill dTrain and mTrain with the sampled data
            for (int i = 0; i < logSamples[0].Count; i++) {
                //Check if this row is valid
                if (!float.IsNaN(logSamples[0][i])) {
                    for (int j = 0; j < dTrainVars; j++) {
                        ret.dTrain[totalRows, j] = logSamples[j][i];
                    }
                    for (int j = 0; j < mTrainVars; j++)
                    {

                        ret.mTrain[totalRows, j] = logSamples[j + dTrainVars][i];
                    }
                    totalRows++;
                }
            }

            ret.gridSize = gridSize;

            return ret;
        }

    }

}
