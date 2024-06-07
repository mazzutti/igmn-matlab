using System;
using System.Collections.Generic;
using System.Linq;

using Slb.Ocean.Petrel;
using Slb.Ocean.Core;
using Slb.Ocean.Basics;
using Slb.Ocean.Petrel.DomainObject;
using Slb.Ocean.Petrel.DomainObject.Seismic;
using static Slb.Ocean.Petrel.DomainObject.Seismic.SeismicLine3D;
using Slb.Ocean.Geometry;

using Slb.Ocean.Petrel.DomainObject.ColorTables;
using Slb.Ocean.Data.Hosting;
using Slb.Ocean.Petrel.Basics;
using Slb.Ocean.Petrel.UI;

//This class encapsulates access to Petrel objects and implements auxiliary functions to
//extract data from the Petrel project tree.
//These functions are not related to any particular plugin.

namespace ModelSRP
{
    public static class PetrelObjectWrapper
    {
        /// <summary>Reads all the samples of a SeismicCube.</summary>
        /// <param name="cube">Seismic cube that will provide the data.</param>
        /// <returns>A 3D array with all the sampled data.</returns>
        public static float[,,] ReadCube(SeismicCube cube)
        {
            if (cube == null) return null;

            var cubeAccess = cube.GetAsyncSubCubeReadOnly(new Index3(0, 0, 0), cube.NumSamplesIJK - 1);
            var ret = cubeAccess.ToArray();
            cubeAccess.Dispose();

            return ret;
        }

        /// <summary>Reads the samples of a TraceView on a SeismicCube.</summary>
        /// <param name="cube">Seismic cube that will provide the data.</param>
        /// <param name="traceData">Subset of traces that will be actually loaded.</param>
        /// <returns>A 3D array with all the sampled data, the first dimension is always length 1.</returns>
        public static float[,,] ReadTraceView(SeismicCube cube, SeismicLine3D sLine)
        {
            var cubeAccess = cube.GetAsyncSubCubeReadOnly(new Index3(0, 0, 0), cube.NumSamplesIJK - 1);
            var traceData = sLine.TraceView;

            var ret = new float[1, FilteredTraces(traceData, sLine.SeismicCube, cube).Count(), cube.NumSamplesIJK.K];
            int traceIndex = 0;
            foreach (var (I, J) in FilteredTraces(traceData, sLine.SeismicCube, cube)) {
                var cubeTrace = cube.GetTrace(I, J);
                for (int k = 0; k < cube.NumSamplesIJK.K; k++) {
                    ret[0, traceIndex, k] = cubeTrace[k];
                }
                traceIndex++;
            }

            cubeAccess.Dispose();

            return ret;
        }

        /// <summary>Gets an existing object in a seismic collection based on a matching rule.
        /// If the object exists but doesn't comply with the compatibility rule, it's deleted instead.</summary>
        private static T GetOrRemove<T>(IEnumerable<T> collection, Func<T, bool> match, Func<T, bool> compatible)
        where T : IDeletable => collection.FirstOrDefault(x => match(x)
            && (compatible(x) || ((Func<bool>) delegate { x.Delete(); return false; })() )
        );

        /// <summary>Creates a new SeismicCube in the tree under the specified Seismic Collection.</summary>
        /// <param name="sCollection">The SeismicCollection which will store the new cube.</param>
        /// <param name="similarCube">A Seismic Cube from which the new cube gets its inherited properties, ex: Seismic Collection tree properties and size.</param>
        /// <param name="dataBuffer">3D array with the data that will be written.</param>
        /// <param name="cubeName">Name of the new cube in the tree.</param>
        /// <param name="template">The Template for the new cube.</param>
        /// <returns>The cube that was created or null if there as an error. </returns>
        public static SeismicCube WriteCube(SeismicCollection sCollection, SeismicCube similarCube, in float[,,] dataBuffer, string cubeName, Template template)
        {
            SeismicCube newCube = null;

            using (ITransaction tr = DataManager.NewTransaction())
            {
                //Lock parent Seismic
                tr.Lock(sCollection);

                //Create new Seismic Cubic if there isn't already one on the tree 
                newCube = GetOrRemove(sCollection.SeismicCubes,
                    x => x.Name == cubeName,
                    x => x.NumSamplesIJK.Equals(similarCube.NumSamplesIJK)) ??
                    sCollection.CreateSeismicCube(similarCube, typeof(float), template, similarCube.ClippingRange);
                
                tr.Lock(newCube);
                newCube.Name = cubeName;

                var AsyncCube_newCube = newCube.GetAsyncSubCubeReadWrite(new Index3(0, 0, 0), similarCube.NumSamplesIJK - 1);
 
                //Copy 3D array into Seismic Cube
                AsyncCube_newCube.CopyFrom(dataBuffer);

                newCube.ActualRange = new Range1<double>(0.0, 0.0);

                tr.Commit();

                AsyncCube_newCube.Dispose();
            }

            return newCube;
        }

        //TraceData that was generated from a TraceView of a multiplanar intersection might have duplicate traces at the corners
        //The duplicated values will cause exceptions when used as input for a new SeismicLine2DCollection, they must be filtered.
        //TODO: Create this as a fixed list and store on IGMNInputResults. (This function was originally not that complex, now it's
        //a bit costly and shouldn't be executed multiple times since it can be avoided)
        private static IEnumerable<(int I, int J)> FilteredTraces(TraceData traceData, SeismicCube origCube, SeismicCube refCube) {
            int oldX = traceData.GetTrace(0).I - 1;
            int oldY = 0;
            foreach (var trace in traceData.Traces)
            {
                var localIndex = refCube.IndexAtPosition(origCube.PositionAtIndex(new IndexDouble3(trace.I, trace.J, 0)));
                int traceI = (int)Math.Round(localIndex.I);
                int traceJ = (int)Math.Round(localIndex.J);
                if ((oldX != traceI) || (oldY != traceJ))
                {
                    if ((traceI >= 0) && (traceJ >= 0) && (traceI < refCube.NumSamplesIJK.I) && (traceJ < refCube.NumSamplesIJK.J)) {
                        oldX = traceI;
                        oldY = traceJ;
                        yield return (traceI, traceJ);
                    }
                }
            }
        }

        /// <summary>Creates a new SeismicLine2DCollection with a new SeismicLine2D in the tree under the specified Seismic Collection.</summary>
        /// <param name="sCollection">The SeismicCollection which will store the new seismic line.</param>
        /// <param name="sLine">The general intersection that will be used to define the shape and provide coordinate information for the new seismic line.</param>
        /// <param name="refCube">SeismicCube (or equivalent reference) that is being intercepted by the SeismicLine3D.</param>
        /// <param name="dataBuffer">3D array with the data that will be written.</param>
        /// <param name="seismic2DName">The name of the new seismic line.</param>
        /// <param name="template">The Template for the new seismic line.</param>
        /// <returns>The cube that was created or null if there as an error. </returns>
        public static SeismicLine2DCollection WriteSeismic2D(SeismicCollection sCollection, SeismicLine3D sLine, SeismicCube refCube, in float[,,] dataBuffer, string seismic2DName, Template template)
        {
            TraceData traceData = sLine.TraceView;
            if ((traceData == null) || (traceData.TraceCount <=0)) return null;

            double rangeMin = double.PositiveInfinity;
            double rangeMax = double.NegativeInfinity;
            double[] xPos = new double[traceData.TraceCount];
            double[] yPos = new double[traceData.TraceCount];

            int finalTraceCount = 0;
            foreach (var (I, J) in FilteredTraces(traceData, sLine.SeismicCube, refCube)) {
                xPos[finalTraceCount] = I;
                yPos[finalTraceCount] = J;
                for (int k = 0; k < refCube.NumSamplesIJK.K; k++)
                {
                    double traceValue = dataBuffer[0, finalTraceCount, k];
                    if (traceValue < rangeMin) rangeMin = traceValue;
                    if (traceValue > rangeMax) rangeMax = traceValue;
                }
                finalTraceCount++;
            }

            SeismicLine2DCollection newLine2DCollection = null;

            SeismicLine2D newLine2D = null;

            using (ITransaction tr = DataManager.NewTransaction())
            {
                tr.Lock(sCollection);

                newLine2DCollection =
                    GetOrRemove(sCollection.SeismicLine2DCollections,
                    x => x.Name == seismic2DName,
                    x => x.First().Traces.Count() == finalTraceCount && x.First().GetTrace(0).Length == refCube.NumSamplesIJK.K);

                if (newLine2DCollection == null)
                {
                    refCube.SpatialLattice.OriginalLattice.Operations.IndexToWorld(xPos, yPos);

                    var traceLines = new Polyline2(xPos.Zip(yPos, (x, y) => new Point2(x, y)).Take(finalTraceCount));

                    var zeros = new float[finalTraceCount];

                    Index2 planeSize = new Index2(finalTraceCount, refCube.NumSamplesIJK.K);

                    double cubeTop = refCube.PositionAtIndex(new IndexDouble3(0, 0, 0)).Z;
                    double cubeBottom = refCube.PositionAtIndex(new IndexDouble3(0, 0, refCube.NumSamplesIJK.K)).Z;

                    newLine2DCollection = sCollection.CreateSeismicLine2DCollection(
                        seismic2DName, traceLines, zeros, zeros, planeSize, refCube.Origin.Z,
                        (cubeTop - cubeBottom) / (double)refCube.NumSamplesIJK.K, refCube.StorageType, refCube.Domain,
                        template, new Range1<double>(rangeMin, rangeMax));
                }

                //SeismicLine2DCollections always have only one SeismicLine2D
                newLine2D = newLine2DCollection.First();

                tr.Lock(newLine2D);

                int destIndex = 0;
                foreach (var destTrace in newLine2D.Traces) {
                    for (int k = 0; k < destTrace.Length; k++) {
                        destTrace[k] = dataBuffer[0, destIndex, k];
                    }
                    destIndex++;
                }

                tr.Lock(newLine2DCollection);
                newLine2DCollection.ActualRange =
                    (!double.IsInfinity(rangeMin) && !double.IsInfinity(rangeMax) && (rangeMin < rangeMax)) ?
                        new Range1<double>(rangeMin, rangeMax) :
                        new Range1<double>(0, 0);
                tr.Commit();
            }

            //Force the visualization to refrsh on any 3D window (this doesn't automatically happen with SeismicLine2Ds)
            foreach(Window3D window in PetrelProject.ToggleWindows.Where(x => x is Window3D)) {
                if (window.IsVisible(newLine2D)) {
                    window.HideObject(newLine2D);
                    window.ShowObject(newLine2D);
                }
            }

            return newLine2DCollection;
        }

        /// <summary>Creates or returns an existing folder (SeismicCollection) under a SeismicProject.</summary>
        /// <param name="folderName">The name of the collection.</param>
        /// <returns>The collection with the specified name. </returns>
        public static SeismicCollection CreateOrReplaceFolder(string folderName, SeismicProject p)
        {
            return p.SeismicCollections.Where(x => x.Name == folderName)
                .Select<SeismicCollection, Func<SeismicCollection>>(x => () => x)
                .DefaultIfEmpty(() => p.CreateSeismicCollection(folderName)).First()();
        }

        /// <summary>Creates or returns an existing folder (SeismicCollection) under another SeismicCollection.</summary>
        /// <param name="folderName">The name of the collection.</param>
        /// <returns>The collection with the specified name. </returns>
        public static SeismicCollection CreateOrReplaceFolder(string folderName, SeismicCollection c)
        {
            return c.SeismicCollections.Where(x => x.Name == folderName)
                .Select<SeismicCollection, Func<SeismicCollection>>(x => () => x)
                .DefaultIfEmpty(() => c.CreateSeismicCollection(folderName)).First()();
        }

        /// <summary>Copies the ColorTable from a domain object into another.</summary>
        /// <param name="domainObject">The domain object for which the new ColorTable will be set.</param>
        /// <param name="refDomainObject">The domain object that will provide the new ColorTable.</param>
        public static void SetColorTable(IDomainObject domainObject, IDomainObject refDomainObject)
        {
            if ((domainObject == null) || (refDomainObject == null)) return;

            ColorTableRoot colorTableRoot = ColorTableRoot.Get(PetrelProject.PrimaryProject);
            if (colorTableRoot == null) return;

            using (ITransaction transaction = DataManager.NewTransaction())
            {
                transaction.Lock(refDomainObject);
                var refColorTableAccess = colorTableRoot.GetColorTableAccess(refDomainObject);
                transaction.Lock(refColorTableAccess);

                transaction.Lock(domainObject);
                var colorTableAccess = colorTableRoot.GetColorTableAccess(domainObject);
                transaction.Lock(colorTableAccess);

                if (refColorTableAccess.ColorTableScope == ColorTableScope.Private)
                {
                    colorTableAccess.ColorTableScope = ColorTableScope.Private;
                    colorTableAccess.LimitStrategy = refColorTableAccess.LimitStrategy;
                    colorTableAccess.ColorControlPoints = refColorTableAccess.ColorControlPoints;
                } else {
                    colorTableAccess.SharedColorTable = refColorTableAccess.SharedColorTable;
                }
                transaction.Commit();
            }
        }

        public class SelectableItem
        {
            public SelectableItem(object _item){
                item = _item;
                selected = false;
            }
            public SelectableItem(object _item, bool _selected)
            {
                item = _item;
                selected = _selected;
            }
            public object item;
            public bool selected;
        }

    }
}
