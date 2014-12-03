package input;

enum MouseButton
{
    MouseButtonLeft;
    MouseButtonRight;
    MouseButtonMiddle;
    MouseButtonWheel(delta: Float);
    MouseButtonOther(name: String);
}