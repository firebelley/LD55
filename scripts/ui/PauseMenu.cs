using Game.Autoload;
using Godot;
using GodotUtilities;

namespace Game.UI
{
    [Scene]
    public partial class PauseMenu : CanvasLayer
    {
        [Signal]
        public delegate void LevelSelectPressedEventHandler();

        [Node]
        private Button optionsButton;
        [Node]
        private Button resumeButton;
        [Node]
        private Button quitButton;

        public override void _Notification(int what)
        {
            if (what == NotificationSceneInstantiated)
            {
                WireNodes();
            }
            else if (what == NotificationExitTree)
            {
                GetTree().Paused = false;
            }
        }

        public override void _Ready()
        {
            GetTree().Paused = true;
            optionsButton.Connect("pressed", new Callable(this, nameof(OnOptionsPressed)));
            resumeButton.Connect("pressed", new Callable(this, nameof(OnResumePressed)));
            quitButton.Connect("pressed", new Callable(this, nameof(OnQuitPressed)));
        }

        public override void _UnhandledInput(InputEvent evt)
        {
            if (evt.IsActionPressed("pause"))
            {
                GetViewport().SetInputAsHandled();
                OnResumePressed();
            }
        }

        public override void _Process(double delta)
        {
            if (!GetTree().Paused)
            {
                QueueFree();
            }
        }

        private async void OnOptionsPressed()
        {
            GetNode("/root/ScreenTransition").Call("transition");
            await ToSignal(GetNode("/root/ScreenTransition"), "transitioned_halfway");
            var options = GD.Load<PackedScene>("res://scenes/ui/OptionsMenu.tscn");
            AddChild(options.Instantiate());
        }

        private void OnResumePressed()
        {
            GetTree().Paused = false;
        }

        private async void OnQuitPressed()
        {
            GetNode("/root/ScreenTransition").Call("transition");
            await ToSignal(GetNode("/root/ScreenTransition"), "transitioned_halfway");
            GetTree().Paused = false;
            GetTree().ChangeSceneToFile("res://scenes/Title.tscn");
        }
    }
}
