
using ControllerSRP;
using InterfaceSRP;
using Slb.Ocean.Petrel;
using Slb.Ocean.Petrel.Commands;

namespace IGMNRockPhysics
{
    class IGMNInversion : SimpleCommandHandler
    {
        public static string ID = "IGMNRockPhysics.IGMNInversion";

        #region SimpleCommandHandler Members

        public override bool CanExecute(Slb.Ocean.Petrel.Contexts.Context context)
        {
            return true;
        }

        public override void Execute(Slb.Ocean.Petrel.Contexts.Context context)
        {
            var window = new IGMNInversionWindow();
            _ = new IGMNInversionController(window);
            PetrelSystem.ShowModeless(window);
        }

        #endregion
    }
}
