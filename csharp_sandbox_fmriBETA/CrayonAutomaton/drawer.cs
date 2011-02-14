using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Drawing.Drawing2D;
using System.Drawing;
using System.Threading;
using System.Windows.Forms;

namespace CrayonAutomaton {
    public class DrawingObject {
        public GraphicsPath Path { get; set; }
        public int PerMovePause { get; set; }
        public DrawingObject(GraphicsPath path, int perMovePause) {
            Path = path;
            PerMovePause = perMovePause;
        }
        public void Draw() {
            MouseInput input = new MouseInput(PerMovePause, true);
            int index=0;
            PointF firstPoint = new PointF();// = null;
            foreach (PointF point in Path.PathPoints) {
                byte curType = Path.PathTypes[index];
                byte itemType = (byte)(curType & (byte)PathPointType.PathTypeMask);

                /* Draw different types of objects */
                if (itemType == (byte)PathPointType.Start) {
                    firstPoint = point;
                    input.MousePos(point);
                    input.LeftButtonDown();
                } else if ((itemType == (byte)PathPointType.Line) || (itemType == (byte)PathPointType.Bezier) || (itemType == (byte)PathPointType.Bezier3))
                    input.MousePos(point);

                /* Handle flags */
                if (isType(curType, PathPointType.PathMarker)) {
                    bool wasMouseDown = false;
                    if (input.IsMouseDown) {
                        wasMouseDown = true;
                        input.LeftButtonUp();
                    }
                    input.MousePos(point);
                    if (wasMouseDown)
                        input.LeftButtonDown();
                }

                if (isType(curType, PathPointType.CloseSubpath)) {
                    input.MousePos(firstPoint);
                    input.LeftButtonUp();
                }
                index++;
            }
            input.LeftButtonUp();
            input.Run();
        }
        private bool isType(byte type, PathPointType isType) {
            return (type & (byte)isType) != 0;
        }
    }
    public class MouseInput {
        #region win32api
        [DllImport("user32.dll", EntryPoint = "SendInput", SetLastError = true)]
        static extern uint SendInput(uint nInputs, INPUT pInputs, int cbSize);
        [DllImport("user32.dll", EntryPoint = "SendInput", SetLastError = true)]
        static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
        public struct INPUT {
            public int type;
            public MOUSEINPUT mi;
        }
        public struct MOUSEINPUT {
            public int dx;
            public int dy;
            public int mouseData;
            public int dwFlags;
            public int time;
            public int dwExtraInfo;
        }
        [Flags()]
        private enum MouseEvents {
            Move = 0x0001,  // mouse move 
            LeftDown = 0x0002,  // left button down
            LeftUp = 0x0004,  // left button up
            RightDown = 0x0008,  // right button down
            RightUp = 0x0010,  // right button up
            MiddleDown = 0x0020,  // middle button down
            MiddleUp = 0x0040,  // middle button up
            XDown = 0x0080,  // x button down 
            XUp = 0x0100,  // x button down
            Wheel = 0x0800,  // wheel button rolled
            VirtualDesk = 0x4000,  // map to entire virtual desktop
            Absolute = 0x8000,  // absolute move
        }
        #endregion

        public List<INPUT> Inputs { get; set; }
        public int PerstepPause { get; set; }
        public bool ExecuteEachStep { get; set; }
        public bool IsMouseDown { get; set; }

        Size monitorSize = SystemInformation.PrimaryMonitorSize;

        public MouseInput(int perstepPause) : this(perstepPause, false) { }
        public MouseInput(bool executeEachStep) : this(0, executeEachStep) { }
        public MouseInput(int perstepPause, bool executeEachStep) {
            Inputs = new List<INPUT>();
            IsMouseDown = false;
            PerstepPause = perstepPause;
            ExecuteEachStep = executeEachStep;
        }

        public void MousePos(PointF point) { MousePos((int)Math.Ceiling(point.X), (int)Math.Ceiling(point.Y)); }
        public void MousePos(Point point) { MousePos(point.X, point.Y); }
        public void MousePos(int x, int y) {
            setMouseInput(x * 65535 / monitorSize.Width, y * 65535 / monitorSize.Height, 0, MouseEvents.Absolute | MouseEvents.Move);
        }
        public void LeftButtonDown() {
            setMouseInput(MouseEvents.LeftDown);
            IsMouseDown = true;
        }
        public void LeftButtonUp() {
            setMouseInput(MouseEvents.LeftUp);
            IsMouseDown = false;
        }

        public void Run() {
            if (Inputs.Count == 0)
                return;
            else {
                foreach (INPUT curInput in Inputs) {
                    SendInput(1, new INPUT[] { curInput }, Marshal.SizeOf(curInput));
                    if (PerstepPause > 0)
                        Thread.Sleep(PerstepPause);
                }
            }
        }

        private void setMouseInput(MouseEvents dwFlags) { setMouseInput(0, 0, 0, dwFlags); }
        private void setMouseInput(int mouseData, MouseEvents dwFlags) { setMouseInput(0, 0, mouseData, dwFlags); }
        private void setMouseInput(int x, int y, int mouseData, MouseEvents dwFlags) {
            INPUT input = new INPUT();
            input.mi.dx = x;
            input.mi.dy = y;
            input.mi.mouseData = mouseData;
            input.mi.dwFlags = (int)dwFlags;
            if (ExecuteEachStep) {
                SendInput(1, new INPUT[] { input }, Marshal.SizeOf(input));
                if (PerstepPause > 0)
                    Thread.Sleep(PerstepPause);
            } else
                Inputs.Add(input);
        }


    }
}
