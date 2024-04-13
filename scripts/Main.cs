using Godot;
using GodotUtilities;

namespace Game
{
    [Scene]
    public partial class Main : Node
    {
        [Node]
        private Node test;

        public override void _Notification(int what)
        {
            if (what == NotificationSceneInstantiated)
            {
                WireNodes();
            }
        }

        public override void _EnterTree()
        {
            GD.Print("hello");
            GD.Print(test);
        }
    }
}
