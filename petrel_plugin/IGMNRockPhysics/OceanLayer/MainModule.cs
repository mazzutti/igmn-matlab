using Slb.Ocean.Core;
using Slb.Ocean.Petrel;

namespace IGMNRockPhysics
{
    /// <summary>
    /// This class will control the lifecycle of the Module.
    /// The order of the methods are the same as the calling order.
    /// </summary>
    public class MainModule : IModule
    {
        public MainModule()
        {
            //
            // TODO: Add constructor logic here
            //
#if DEBUG
            System.Diagnostics.Debugger.Launch();
#endif
        }

        #region IModule Members

        /// <summary>
        /// This method runs once in the Module life; when it loaded into the petrel.
        /// This method called first.
        /// </summary>
        public void Initialize()
        {
            // TODO:  Add MainModule.Initialize implementation
        }

        /// <summary>
        /// This method runs once in the Module life. 
        /// In this method, you can do registrations of the not UI related components.
        /// (eg: datasource, plugin)
        /// </summary>
        public void Integrate()
        {
            // Register IGMNInversion
            PetrelSystem.CommandManager.CreateCommand(IGMNRockPhysics.IGMNInversion.ID, new IGMNRockPhysics.IGMNInversion());

            // TODO:  Add MainModule.Integrate implementation
        }

        /// <summary>
        /// This method runs once in the Module life. 
        /// In this method, you can do registrations of the UI related components.
        /// (eg: settingspages, treeextensions)
        /// </summary>
        public void IntegratePresentation()
        {
            // Add Ribbon Configuration file
            PetrelSystem.ConfigurationService.AddConfiguration(IGMNRockPhysics.Properties.Resources.OceanRibbonConfiguration);

            // TODO:  Add MainModule.IntegratePresentation implementation
        }

        /// <summary>
        /// This method runs once in the Module life.
        /// right before the module is unloaded. 
        /// It usually happens when the application is closing.
        /// </summary>
        public void Disintegrate()
        {
            // TODO:  Add MainModule.Disintegrate implementation
        }

        #endregion

        #region IDisposable Members

        public void Dispose()
        {
            // TODO:  Add MainModule.Dispose implementation
        }

        #endregion

    }


}