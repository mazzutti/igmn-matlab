using System.Collections.Generic;

using Slb.Ocean.Petrel;
using Slb.Ocean.Petrel.DomainObject;
using Slb.Ocean.Petrel.DomainObject.Well;
using Slb.Ocean.Petrel.DomainObject.Seismic;

using static ModelSRP.PetrelObjectWrapper;
using Slb.Ocean.Data.Hosting;

//This class contain the structures specific to the IGMN Inversion module.
//It also contains functions that access Petrel objects directly
//Generic structures for Petrel objects can be found in PetrelObjectWrapper.

namespace ModelSRP
{
    public static class IGMNInversionModel
    {

        public class WellLogInfo
        {
            public WellLogInfo(IDomainObject domainObj, Template wellLogTemplate) {
                refereceObject = domainObj;
                template = wellLogTemplate;
            }
            public IDomainObject refereceObject;
            public Template template;
        }

        public class InputSeismicCube
        {
            public SeismicCube pCube;
            public WellLog wellLog;
        }

        public class OutputSeismicCube
        {
            public string cubeName;
            public WellLogInfo logType;
        }

        public class WellZoneItemPair
        {
            public Borehole well;
            public BoreholeZone boreholeZone;
        }

        public class IGMNInversionInput
        {
            public float[][,,] dCond;
            public float[,] dTrain;
            public float[,] mTrain;
            public float gridSize;
        }

        public class IGMNInversionOutput
        {
            public IGMNInversionOutput() { }
            public IGMNInversionOutput(int cubeAmt, int i, int j, int k) {
                outCubes = new float[cubeAmt][,,];
                for (int n = 0; n < cubeAmt; n++) {
                    outCubes[n] = new float[i, j, k];
                }
            }
            public float[][,,] outCubes;
        }

        /// <summary>Lists all available wells in the current project as selectable items.</summary>
        public static List<SelectableItem> GetProjectWells()
        {
            List<SelectableItem> ret = new List<SelectableItem>();

            //TO DO: Remove this validation for the release
            try { Project x = PetrelProject.PrimaryProject; } catch { return ret; }

            IEnumerable<BoreholeCollection> projWells = WellRoot.Get(PetrelProject.PrimaryProject).BoreholeCollection.BoreholeCollections;

            foreach (var boreholeCollection in projWells)
            {
                foreach (var borehole in boreholeCollection)
                {
                    SelectableItem newItem = new SelectableItem(borehole)
                    {
                        selected = false
                    };
                    ret.Add(newItem);
                }
            }
            return ret;
        }

        /// <summary>Lists all known zones in the current project as selectable items.</summary>
        public static List<SelectableItem> GetProjectZones()
        {
            List<SelectableItem> ret = new List<SelectableItem>();

            //TO DO: Remove this validation for the release
            try { var x = PetrelProject.PrimaryProject; } catch { return ret; }

            var projMarkers = WellRoot.Get(PetrelProject.PrimaryProject).MarkerCollections;

            foreach (var markerCollection in projMarkers)
            {
                foreach (var zone in markerCollection.Zones)
                {
                    ret.Add(new SelectableItem(zone));
                }
            }
            return ret;
        }

    }
}
