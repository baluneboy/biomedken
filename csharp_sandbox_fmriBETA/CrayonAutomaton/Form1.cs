using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Reflection;
using System.Xml.Serialization;
using System.Xml;
using System.IO;
using System.Drawing.Imaging;
using System.Diagnostics;

namespace CrayonAutomaton
{
    public partial class mainForm : Form
    {
        const int defaultRunPause = 2345;
        const int defaultPerMovePause = 67;
        const float version = .4f;
        const bool versionBeta = true;
        const string fileExtention = "pathdata";

        Image levelImage = null;
        enum toolTypes : int { Unknown = 0, Rectangle, Line, Circle, Free, Text, Pointer }
        string[] toolTypeDescriptions = new string[] { "", "Rectangle", "Line", "Circle", "Free Hand", "Text", "Pointer" };
        toolTypes curTool = toolTypes.Unknown;
        GraphicsPath path = new GraphicsPath();
        Point mouseDownPoint = new Point();
        bool waitForDeactivate = true;
        bool running = false;
        //string windowCaption = null;
        bool hasChanged = false;    //tells if the path has been changed since last save
        bool freeDrawAllowed = true; //used by the timer to change the free draw resolution
        bool showNodeRects = true;
        bool nodeDetection = true;
        bool autoStartFigure = true;
        /// <summary>the invisible (or visible!) seperator that indicates the start of the tools list.</summary>
        ToolStripSeparator startOfToolsSeperator;
        int capturedPointIndex = -1;
        List<int> hoveredNodes = new List<int>();
        StringBuilder hoveredNodesString = new StringBuilder();
        bool updateHoveredNodes = false;
        GraphicsPath previewGraphicsPath = new GraphicsPath();
        GraphicsPath displayGrid = new GraphicsPath();
        bool displayDisplayGrid = true;
        bool snapToDisplayGrid = true;
        Size gridSize = new Size(20, 20);

        public mainForm()
        {
            InitializeComponent();
            levelBox.Paint += new PaintEventHandler(levelBox_Paint);
            levelBox.MouseDown += new MouseEventHandler(levelBox_MouseDown);
            levelBox.MouseUp += new MouseEventHandler(levelBox_MouseUp);
            levelBox.MouseMove += new MouseEventHandler(levelBox_MouseMove);
            levelBox.MouseLeave += new EventHandler(levelBox_MouseLeave);
            levelBox.MouseEnter += new EventHandler(levelBox_MouseEnter);
            perMovePauseTextBox.KeyUp += new KeyEventHandler(validateTextBox_KeyUp);
            runPauseTextBox.KeyUp += new KeyEventHandler(validateTextBox_KeyUp);
            this.Deactivate += new EventHandler(Form1_Deactivate);

            /* Load controls with default values */
            runPauseTextBox.Text = defaultRunPause.ToString();
            perMovePauseTextBox.Text = defaultPerMovePause.ToString();
            runWaitsForToolStripMenuItem.Checked = waitForDeactivate;
            showNodeRectanglesToolStripMenuItem.Checked = showNodeRects;
            detectedHoveredNodesToolStripMenuItem.Checked = nodeDetection;
            automaticallyStartNewFigureToolStripMenuItem.Checked = autoStartFigure;
            displayGridToolStripMenuItem.Checked = displayDisplayGrid;
            snapToGridToolStripMenuItem.Checked = snapToDisplayGrid;

            /* Create grid with start values */
            generateGrid();

            /* Show version in window caption */
            Text += string.Format(" ({0}{1})", version, versionBeta ? " beta" : "");

            /* Create tool bar list of drawing tools */
            int index = 0;
            int insertIndex = 0;
            startOfToolsSeperator = new ToolStripSeparator();
            if (insertIndex == 0)   //surpress visibility if first item.
                startOfToolsSeperator.Visible = false;
            drawToolStrip.Items.Insert(insertIndex++, startOfToolsSeperator);
            foreach (string curTool in toolTypeDescriptions)
            {
                if (!string.IsNullOrEmpty(curTool))
                {
                    ToolStripButton curButton = new ToolStripButton(curTool, null, toolMenuItem_Click);
                    curButton.Tag = index;
                    curButton.ToolTipText = curTool;
                    curButton.CheckOnClick = true;
                    drawToolStrip.Items.Insert(insertIndex++, curButton);
                }
                index++;
            }

            updateStatusBar();
        }

        void updateStatusBar()
        {
            //Text = string.Format("{0} (Point Count: {1}){2}", windowCaption, path.PointCount, hasChanged ? " *" : "");
            nodeCountStatusLabel.Text = "Node Count: " + path.PointCount;
            changedStatusLabel.Text = hasChanged ? "Unsaved" : "";
        }
        void redrawLevel()
        {
            levelBox.Invalidate();
            updateStatusBar();
        }
        private int isValidUInt(string text)
        {
            uint num;
            if (uint.TryParse(text, out num))
                return (int)num;
            return -1;
        }
        private int getRunPause()
        {
            int num = isValidUInt(runPauseTextBox.Text);
            if (num == -1)
                return defaultRunPause;
            return num;
        }
        private int getPerMovePause()
        {
            int num = isValidUInt(perMovePauseTextBox.Text);
            if (num == -1)
                return defaultPerMovePause;
            return num;
        }
        private void run()
        {
            running = false;
            System.Threading.Thread.Sleep(getRunPause());
            DrawingObject mouseDraw = new DrawingObject(path, getPerMovePause());
            mouseDraw.Draw();
        }
        private void savePathData(string filename)
        {
            StreamWriter w = new StreamWriter(filename);
            XmlSerializer s = new XmlSerializer(path.PathData.GetType());
            s.Serialize(w, path.PathData);
            w.Close();
        }
        private PathData loadPathData(string filename)
        {
            if (File.Exists(filename))
            {
                XmlSerializer deserializer = new XmlSerializer(typeof(PathData));
                TextReader textReader = new StreamReader(filename);
                PathData data = new PathData();
                data = (PathData)deserializer.Deserialize(textReader);
                textReader.Close();
                return data;
            }
            return null;
        }

        void Form1_Deactivate(object sender, EventArgs e)
        {
            if ((waitForDeactivate) && (running))
                run();
        }
        /// <summary>Red out boxes with non-numeric input inside of them</summary>
        void validateTextBox_KeyUp(object sender, KeyEventArgs e)
        {
            ((ToolStripTextBox)sender).BackColor = isValidUInt(((ToolStripTextBox)sender).Text) == -1 ? Color.Red : SystemColors.Window;
        }
        void levelBox_MouseEnter(object sender, EventArgs e)
        {
            hoveredNodesTimer.Enabled = true;
        }
        void levelBox_MouseLeave(object sender, EventArgs e)
        {
            hoveredNodesTimer.Enabled = false;
        }
        void levelBox_MouseDown(object sender, MouseEventArgs e)
        {
            /* Start new figure */
            if (autoStartFigure)
                path.StartFigure();

            /* Store initial mouse down point */
            mouseDownPoint = gridPositionFromPoint(e.Location);

            /* Tool specific events */
            if (curTool == toolTypes.Free)
                freeDrawResolutionTimer.Start();
            else if (curTool == toolTypes.Pointer)
                capturedPointIndex = nodeIndexFromPoint(e.Location);
        }
        void levelBox_MouseMove(object sender, MouseEventArgs e)
        {
            /* Do free draw */
            if ((curTool == toolTypes.Free) && freeDrawAllowed)
            {
                if (mouseDownPoint != e.Location)
                {
                    path.AddLine(mouseDownPoint, e.Location);
                    mouseDownPoint = e.Location;
                    freeDrawAllowed = false;
                }
            }

            /* Discover nodes being hovered over */
            if (nodeDetection && updateHoveredNodes)
            {
                List<int> oldHoveredNodes = new List<int>(hoveredNodes);
                hoveredNodes = new List<int>(nodeIndexesFromPoint(e.Location));
                if (hoveredNodes.Count > 0)
                {
                    hoveredNodesString = new StringBuilder(" Nodes: {");
                    foreach (int curNode in hoveredNodes)
                        hoveredNodesString.Append(path.PathPoints[curNode]);
                    hoveredNodesString.Append("}");
                }
                else
                    hoveredNodesString = new StringBuilder();
                /* Redraw only when hovered nodes change */
                if (oldHoveredNodes != hoveredNodes)
                    redrawLevel();
                updateHoveredNodes = false;
            }

            /* Draw shape previews */
            if (e.Button == MouseButtons.Left)
            {
                previewGraphicsPath.Reset();
                drawInputToPath(previewGraphicsPath, gridPositionFromPoint(e.Location));
            }

            /* Update status strip */
            mousePosStatusLabel.Text = string.Format("Mouse: {0} Canvas: {1}{2}",
                e.Location, levelBox.Size,
                (hoveredNodes.Count > 0) ? hoveredNodesString.ToString() : "");
        }
        private void hoveredNodesTimer_Tick(object sender, EventArgs e)
        {
            updateHoveredNodes = true;
        }
        void levelBox_MouseUp(object sender, MouseEventArgs e)
        {
            /* BROKEN: Do not render if right mouse button is pushed */
            if (e.Button == MouseButtons.Right)
                return;

            Point endPoint = gridPositionFromPoint(e.Location);

            if ((curTool == toolTypes.Pointer) && (capturedPointIndex != -1))
                path.PathData.Points[capturedPointIndex] = new PointF(endPoint.X, endPoint.Y);
            else if (curTool == toolTypes.Text)
            {
                enterTextDialog textDialog = new enterTextDialog();
                textDialog.PreviewUpdateEvent += new enterTextDialog.PreviewUpdateEventHandler(textDialog_PreviewUpdateEvent);
                if (textDialog.ShowDialog() == DialogResult.OK)
                    addStringFromDialog(path, textDialog);
            }
            else
                drawInputToPath(path, endPoint);
            previewGraphicsPath.Reset();
            hasChanged = true;
            redrawLevel();
        }
        /// <summary>'Snap' argument point to grid, detects if snapping to grid is enabled!</summary>
        Point gridPositionFromPoint(Point point)
        {
            if (!snapToDisplayGrid)
                return point;
            Point gridPoint = new Point();
            gridPoint.X = (int)Math.Floor((decimal)(point.X / gridSize.Width)) * gridSize.Width;
            gridPoint.Y = (int)Math.Floor((decimal)(point.Y / gridSize.Height)) * gridSize.Height;
            if (point.X % gridSize.Width > gridSize.Width / 2)
                gridPoint.X += gridSize.Width;
            if (point.Y % gridSize.Height > gridSize.Height / 2)
                gridPoint.Y += gridSize.Height;
            return gridPoint;
        }
        void generateGrid()
        {
            int gridX = gridSize.Width;
            int gridY = gridSize.Height;
            displayGrid.Reset();
            do
            {
                displayGrid.StartFigure();
                displayGrid.AddLine(gridX, 0, gridX, levelBox.Height);
            } while ((gridX += gridSize.Width) < levelBox.Width);
            do
            {
                displayGrid.StartFigure();
                displayGrid.AddLine(0, gridY, levelBox.Width, gridY);
            } while ((gridY += gridSize.Height) < levelBox.Height);
        }
        void drawInputToPath(GraphicsPath path, Point endPoint)
        {
            int x1 = Math.Min(mouseDownPoint.X, endPoint.X);
            int y1 = Math.Min(mouseDownPoint.Y, endPoint.Y);
            int x2 = Math.Max(mouseDownPoint.X, endPoint.X);
            int y2 = Math.Max(mouseDownPoint.Y, endPoint.Y);
            int width = x2 - x1;
            int height = y2 - y1;
            if (curTool == toolTypes.Rectangle)
                path.AddRectangle(new Rectangle(x1, y1, width, height));
            else if (curTool == toolTypes.Line)
                path.AddLine(mouseDownPoint, endPoint);
            else if (curTool == toolTypes.Circle)
            {
                path.AddEllipse(x1, y1, width, height);
                //Debug.Write(string.Format("Circle: x1 = {0}, y1 = {1}, w = {2}, h = {3}",x1.ToString(),y1.ToString(),width.ToString(),height.ToString()));
                //path = doSomething(path);
            }

        }
        void textDialog_PreviewUpdateEvent(enterTextDialog dialog)
        {
            previewGraphicsPath.Reset();
            addStringFromDialog(previewGraphicsPath, dialog);
            redrawLevel();
        }
        void addStringFromDialog(GraphicsPath path, enterTextDialog dialog)
        {
            path.AddString(dialog.EnteredText,
                dialog.SelectedFont.FontFamily,
                (int)dialog.SelectedFont.Style,
                dialog.SelectedFont.Size,
                mouseDownPoint,
                StringFormat.GenericDefault);
        }
        void toolMenuItem_Click(object sender, EventArgs e)
        {
            curTool = (toolTypes)((ToolStripButton)sender).Tag;

            /* HACK(ish): Enumerate the tool items until tool-indicating seperator is found, uncheck until a new seperator is found */
            bool insideToolSection = false;
            foreach (ToolStripItem curToolItem in drawToolStrip.Items)
                if ((curToolItem is ToolStripButton) && (insideToolSection))
                    ((ToolStripButton)curToolItem).Checked = false;
                else if (curToolItem == startOfToolsSeperator)
                    insideToolSection = true;
                else if (curToolItem is ToolStripSeparator)
                    break;
            ((ToolStripButton)sender).Checked = true;
        }
        GraphicsPath pathPoints = new GraphicsPath();
        GraphicsPath hoveredPathPoints = new GraphicsPath();
        const int pathPointsWidth = 6;
        void levelBox_Paint(object sender, PaintEventArgs e)
        {

            //e.Graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;

            /* Draw background image if one has been given */
            if (levelImage != null)
                e.Graphics.DrawImageUnscaled(levelImage, 0, 0);

            /* Draw grid if enabled */
            if (displayDisplayGrid)
                e.Graphics.DrawPath(Pens.LightGray, displayGrid);

            /* Draw main path data */
            e.Graphics.DrawPath(Pens.Black, path);

            /* Draw node rectangles if activated */
            if ((showNodeRects) && (path.PointCount > 0))
            {
                pathPoints.Reset();
                foreach (PointF curPoint in path.PathPoints)
                    pathPoints.AddRectangle(nodeRectangle(curPoint));
                e.Graphics.DrawPath(Pens.Green, pathPoints);

                /* Draw hovered nodes */
                if (hoveredNodes.Count > 0)
                {
                    pathPoints.Reset();
                    foreach (int curPointIndex in hoveredNodes)
                        if (curPointIndex < path.PointCount)
                            pathPoints.AddRectangle(nodeRectangle(path.PathPoints[curPointIndex]));
                    e.Graphics.DrawPath(Pens.Red, pathPoints);
                }
            }

            /* Draw any previews present */
            e.Graphics.DrawPath(Pens.Red, previewGraphicsPath);

        }
        private IEnumerable<int> nodeIndexesFromPoint(Point point) { return nodeIndexesFromPoint(point, false); }
        private IEnumerable<int> nodeIndexesFromPoint(Point point, bool returnOnlyFirst)
        {
            if (path.PointCount == 0)
                yield break;
            int i = 0;
            foreach (PointF curPoint in path.PathPoints)
            {
                if (nodeRectangle(curPoint).Contains(point))
                {
                    yield return i;
                    if (returnOnlyFirst)
                        yield break;
                }
                i++;
            }
        }
        private int nodeIndexFromPoint(Point point)
        {
            int i = 0;
            foreach (PointF curPoint in path.PathPoints)
            {
                if (nodeRectangle(curPoint).Contains(point))
                    return i;
                i++;
            }
            return -1;
        }
        private RectangleF nodeRectangle(PointF point)
        {
            return new RectangleF(point.X - pathPointsWidth / 2, point.Y - pathPointsWidth / 2, pathPointsWidth, pathPointsWidth);
        }
        private void clearStripButton1_Click(object sender, EventArgs e)
        {
            path.Reset();
            hasChanged = false;
            redrawLevel();
        }
        private void runStripButton_Click(object sender, EventArgs e)
        {
            if (waitForDeactivate)
                running = true;
            else
                run();
        }
        private void closePathStripButton_Click(object sender, EventArgs e)
        {
            path.CloseFigure();
            redrawLevel();
        }
        private void closeAllStripButton_Click(object sender, EventArgs e)
        {
            path.CloseAllFigures();
            redrawLevel();
        }
        private GraphicsPath loadPathData()
        {
            OpenFileDialog openDialog = new OpenFileDialog();
            openDialog.Filter = string.Format("Path Data (*.{0})|*.{0}", fileExtention);
            if (openDialog.ShowDialog() == DialogResult.OK)
            {
                PathData data = loadPathData(openDialog.FileName);
                return new GraphicsPath(data.Points, data.Types);
            }
            return null;
        }
        private GraphicsPath loadPathDataFromKen()
        {
            //return new GraphicsPath(data.Points, data.Types);
            //return RoundedRectangle.Create(908, 350, 150, 150, 11);

            GraphicsPath myPath = new GraphicsPath();
            //Point[] myArray = getSomeArray(new Point(420, 300), new Point(250, 300));
            Point[] myArray = getSimpleArray();
            myPath.AddLines(myArray);
            //myPath = doSomething(myPath);
            return myPath;
        }
        private Point[] getSimpleArray()
        {
            Point[] myArray =
                {
                new Point(400, 300),
                new Point(300, 250),
                new Point(200, 300),
                new Point(300, 350),
                new Point(400, 300)
                };
            return myArray;
        }
        private Point[] getSomeArray(Point pointZero, Point pointSix)
        {
            Point[] anArray =
                {
                new Point(pointZero.X + 5, pointZero.Y + 5),
                new Point(pointZero.X + 11, pointZero.Y + 22)
                };
            return anArray;
        }
        /// <doc>
        /// Trying to figure my way around here.
        /// </doc>
        private GraphicsPath doSomething(GraphicsPath gp)
        {
            PathData pd = gp.PathData;
            PointF pt1 = new Point(300, 300);

            //Add line to somewhere from each pt
            foreach (PointF p in pd.Points)
            {
                gp.AddLine(pt1, p);
            }

            return gp;
        }
        private void saveToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SaveFileDialog saveDialog = new SaveFileDialog();
            saveDialog.AddExtension = true;
            saveDialog.OverwritePrompt = true;
            saveDialog.DefaultExt = fileExtention;
            saveDialog.DereferenceLinks = true;
            saveDialog.Filter = string.Format("Path Data (*.{0})|*.{0}", fileExtention);
            if (saveDialog.ShowDialog() == DialogResult.OK)
            {
                savePathData(saveDialog.FileName);
                hasChanged = false;
            }
        }

        private void loadToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (hasChanged)
                if (MessageBox.Show("Are you sure you wish to load new data? It will overwrite all existing data! (can use ADD instead)", "Sure?", MessageBoxButtons.YesNo) == DialogResult.No)
                    return;

            GraphicsPath data = loadPathData();
            //GraphicsPath data = loadPathDataFromKen();

            if (data != null)
                path = data;
        }

        private void addPathFromFileToolStripMenuItem_Click(object sender, EventArgs e)
        {
            GraphicsPath data = loadPathData();
            if (data != null)
                path.AddPath(data, false);
        }

        private void freeDrawResolutionTimer_Tick(object sender, EventArgs e)
        {
            freeDrawAllowed = true;
        }
        private void runWaitsForToolStripMenuItem_Click(object sender, EventArgs e)
        {
            waitForDeactivate = !waitForDeactivate;
            runWaitsForToolStripMenuItem.Checked = waitForDeactivate;
        }
        private void showNodeRectanglesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            showNodeRects = !showNodeRects;
            showNodeRectanglesToolStripMenuItem.Checked = showNodeRects;
            redrawLevel();
        }

        private void clearBackgroundToolStripMenuItem_Click(object sender, EventArgs e)
        {
            levelImage = null;
            redrawLevel();
        }

        private void pasteClipboardToolStripMenuItem_Click_1(object sender, EventArgs e)
        {
            levelImage = Clipboard.GetImage();
            levelBox.Width = levelImage.Width;
            levelBox.Height = levelImage.Height;
            redrawLevel();
        }

        private void startFigureStripButton_Click(object sender, EventArgs e)
        {
            path.StartFigure();
        }

        private void changeSizeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            enterSizeDialog dialog = new enterSizeDialog(levelBox.Size);
            if (dialog.ShowDialog() == DialogResult.OK)
            {
                levelBox.Size = dialog.EnterSize;
                generateGrid();
                redrawLevel();
            }
        }

        private void detectedHoveredNodesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            nodeDetection = !nodeDetection;
            detectedHoveredNodesToolStripMenuItem.Checked = nodeDetection;
        }

        private void automaticallyStartNewFigureToolStripMenuItem_Click(object sender, EventArgs e)
        {
            autoStartFigure = !autoStartFigure;
            automaticallyStartNewFigureToolStripMenuItem.Checked = autoStartFigure;
        }

        private void displayGridToolStripMenuItem_Click(object sender, EventArgs e)
        {
            displayDisplayGrid = !displayDisplayGrid;
            displayGridToolStripMenuItem.Checked = displayDisplayGrid;
            redrawLevel();
        }

        private void snapToGridToolStripMenuItem_Click(object sender, EventArgs e)
        {
            snapToDisplayGrid = !snapToDisplayGrid;
            snapToGridToolStripMenuItem.Checked = snapToDisplayGrid;
        }

        private void changeGridSizeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            enterSizeDialog dialog = new enterSizeDialog(gridSize);
            if (dialog.ShowDialog() == DialogResult.OK)
            {
                gridSize = dialog.EnterSize;
                generateGrid();
                redrawLevel();
            }
        }

        SaveFileDialog exportDialog = new SaveFileDialog();
        private void saveImageAsToolStripMenuItem_Click(object sender, EventArgs e)
        {

            StringBuilder filtersString = new StringBuilder();
            foreach (ImageCodecInfo curCodec in ImageCodecInfo.GetImageEncoders())
                filtersString.Append(string.Format("{0} ({1})|{1}|", curCodec.FormatDescription, curCodec.FilenameExtension));
            exportDialog.Filter = filtersString.ToString().TrimEnd(new char[] { '|' });
            exportDialog.OverwritePrompt = true;
            if (exportDialog.ShowDialog() == DialogResult.OK)
            {
                ImageCodecInfo codecInfo = ImageCodecInfo.GetImageEncoders()[exportDialog.FilterIndex];
                Bitmap image = new Bitmap(levelBox.Width, levelBox.Height);
                levelBox.DrawToBitmap(image, new Rectangle(Point.Empty, image.Size));
                image.Save(exportDialog.FileName, new ImageFormat(codecInfo.Clsid));
            }

        }

        /// <doc>
        /// Start first with reducing the number of lines in this graphics path
        /// 1. read first point
        /// 2. if x value of next point = x value of last point then skip
        /// 3. if x value of next point != value of last point then...
        /// 3a. make line based on these two points
        /// 3b. add line to new path
        /// 3c. first point = next point 
        /// 4. repeat 1-3c
        /// 5. Repeat 1-4 for both X and Y
        /// </doc>
        private GraphicsPath SmootherPath(GraphicsPath gp)
        {
            PathData pd = gp.PathData;
            PointF pt1 = new Point(-1, -1);

            //First do all values in the X range
            GraphicsPath FixedPath_X = new GraphicsPath();
            foreach (PointF p in pd.Points)
            {
                if (pt1.X == -1)
                {
                    pt1 = p;
                    continue;
                }
                // If I introduced an error factor here I could smooth it out even more
                if (p.X != pt1.X)
                {
                    FixedPath_X.AddLine(pt1, p);
                    pt1 = p;
                }
            }
            FixedPath_X.CloseFigure();

            //Second do all values in the Y range
            pd = FixedPath_X.PathData;
            pt1 = new Point(-1, -1);
            GraphicsPath FixedPath_Y = new GraphicsPath();
            foreach (PointF p in pd.Points)
            {
                if (pt1.Y == -1)
                {
                    pt1 = p;
                    continue;
                }
                // If I introduced an error factor here I could smooth it out even more
                if (p.Y != pt1.Y)
                {
                    FixedPath_Y.AddLine(pt1, p);
                    pt1 = p;
                }
            }
            FixedPath_Y.CloseFigure();

            return FixedPath_Y;
        }

        private void showDebugToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Debug.Write("DBGVIEWCLEAR"); // clears the DebugView utility display

            //SecondSubpathExample(path);
            //GraphicsPath path = loadPathDataFromKen();
            //ShowSubPathInfo(path);
            //AddPathExample(path);

            //SecondSubpathExample(path);

            //ShowSubPathInfo(path);
            //GraphicsPath newPath;
            //newPath = ModifyPathExample(path);
            //ShowSubPathInfo(newPath);
            //path = newPath;

            ShowSubPathInfo(path);
            GraphicsPath newPath = ShowOctaCenter(path);
            ShowSubPathInfo(newPath);
            path = newPath;

        }

        # region myQuestionableCode

        private void NextMarkerExample2(PaintEventArgs e)
        {

            // Create a graphics path.
            GraphicsPath myPath = new GraphicsPath();

            // Set up primitives to add to myPath.
            Point[] myPoints = {new Point(20, 20), new Point(120, 120), 
            new Point(20, 120),new Point(20, 20) };

            Rectangle myRect = new Rectangle(120, 120, 100, 100);

            // Add 3 lines, a rectangle, an ellipse, and 2 markers.
            myPath.AddLines(myPoints);
            myPath.SetMarkers();
            myPath.AddRectangle(myRect);
            myPath.SetMarkers();
            myPath.AddEllipse(220, 220, 100, 100);

            // Get the total number of points for the path,
            // and the arrays of the points and types.
            int myPathPointCount = myPath.PointCount;
            PointF[] myPathPoints = myPath.PathPoints;
            byte[] myPathTypes = myPath.PathTypes;

            // Set up variables for listing all the values of the path's
            // points to the screen.
            int i;
            float j = 20;
            Font myFont = new Font("Arial", 10);
            SolidBrush myBrush = new SolidBrush(Color.Black);

            // List the values for all of path points and types to
            // the left side of the screen.
            for (i = 0; i < myPathPointCount; i++)
            {
                e.Graphics.DrawString(myPathPoints[i].X.ToString() +
                    ", " + myPathPoints[i].Y.ToString() + ", " +
                    myPathTypes[i].ToString(), myFont, myBrush,
                    20, j);

                j += 20;

            }

            // Create a GraphicsPathIterator.
            GraphicsPathIterator myPathIterator = new GraphicsPathIterator(myPath);

            // Rewind the iterator.
            myPathIterator.Rewind();

            // Create a GraphicsPath to receive a section of myPath.
            GraphicsPath myPathSection = new GraphicsPath();

            // Retrieve and list the number of points contained in
            // the first marker to the right side of the screen.
            int markerPoints;
            markerPoints = myPathIterator.NextMarker(myPathSection);
            e.Graphics.DrawString("Marker: 1" + "  Num Points: " +
                markerPoints.ToString(), myFont, myBrush, 200, 20);

        }
        private void ShowPensAndSmoothingMode(PaintEventArgs e)
        {

            // Set the SmoothingMode property to smooth the line.
            e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;

            // Create a new Pen object.
            Pen greenPen = new Pen(Color.Green);

            // Set the width to 6.
            greenPen.Width = 6.0F;

            // Set the DashCap to round.
            greenPen.DashCap = System.Drawing.Drawing2D.DashCap.Round;

            // Create a custom dash pattern.
            greenPen.DashPattern = new float[] { 4.0F, 2.0F, 1.0F, 3.0F };

            // Draw a line.
            e.Graphics.DrawLine(greenPen, 20.0F, 20.0F, 100.0F, 240.0F);

            // Change the SmoothingMode to none.
            e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.None;

            // Draw another line.
            e.Graphics.DrawLine(greenPen, 100.0F, 240.0F, 160.0F, 20.0F);

            // Dispose of the custom pen.
            greenPen.Dispose();
        }

        # endregion myQuestionableCode

        private void ShowSubPathInfo(GraphicsPath gp)
        {
            GraphicsPathIterator iter = new GraphicsPathIterator(gp);
            Debug.Write(string.Format("PATH totalPts={0} (hasCurve={2}) with {1} subpaths",
                iter.Count.ToString(), iter.SubpathCount.ToString(), iter.HasCurve().ToString()));

            int StartIndex;
            int EndIndex;
            int numPoints;
            int i, j;
            string s;
            bool IsClosed;

            // Rewind the Iterator.
            iter.Rewind();

            // List the Subpaths.
            for (i = 0; i < iter.SubpathCount; i++)
            {
                iter.NextSubpath(out StartIndex, out EndIndex, out IsClosed);
                numPoints = EndIndex - StartIndex + 1;

                switch (numPoints)
                {
                    case 2: s = "LINE"; break;
                    case 4: s = "RECT"; break;
                    case 13: s = "OCTA"; break;
                    default: s = "WHAT"; break;
                }
                Debug.Write(string.Format("{3}, index [{0:000}:{1:000}], IsClosed = {2}",
                    StartIndex, EndIndex, IsClosed.ToString(), s));

                for (j = StartIndex; j <= EndIndex; j++)
                {
                    Debug.Write(String.Format("pt[{0}] is {1} of type {2}.",
                        j, gp.PathPoints[j].ToString(), gp.PathTypes[j].ToString("X")));
                }
            }

        }
        public void SecondSubpathExample(GraphicsPath myPath)
        {
            ShowSubPathInfo(myPath);

            Debug.Write("ABOVE IS ENTIRE PATH, BELOW IS THE 2ND SUBPATH");

            // Create a GraphicsPathIterator for myPath.
            GraphicsPathIterator myPathIterator = new
            GraphicsPathIterator(myPath);

            // Rewind the iterator.
            myPathIterator.Rewind();

            // Create the GraphicsPath section.
            GraphicsPath mySubpath = new GraphicsPath();

            // Iterate to the 2nd subpath and list info for that
            int subpathPoints;
            bool IsClosed2;

            // Iterate to the 2nd subpath (note how first arg gets "assigned" ByRef?)
            subpathPoints = myPathIterator.NextSubpath(mySubpath, out IsClosed2);
            subpathPoints = myPathIterator.NextSubpath(mySubpath, out IsClosed2);

            ShowSubPathInfo(mySubpath);

        }
        private GraphicsPath AddPathExample(GraphicsPath gp)
        {
            // Create the first pathright side up triangle.
            Point[] myArray =
            {
                new Point(30,30),
                new Point(60,60),
                new Point(0,60),
                new Point(30,30)
            };
            GraphicsPath myPath = new GraphicsPath();
            myPath.AddLines(myArray);
            // Create the second pathinverted triangle.
            Point[] myArray2 =
            {
                new Point(30,30),
                new Point(0,0),
                new Point(60,0),
                new Point(30,30)
            };
            GraphicsPath myPath2 = new GraphicsPath();
            myPath2.AddLines(myArray2);
            // Add the second path to the first path.
            myPath.AddPath(myPath2, true);

            // draw a graphic path with bezier curves
            GraphicsPath myPath3 = new GraphicsPath(new Point[] {
                new Point(40, 140), new Point(275, 200),
                new Point(105, 225), new Point(190, ClientRectangle.Bottom),
                new Point(50, ClientRectangle.Bottom), new Point(20, 180), },
             new byte[] {
                (byte)PathPointType.Start,
                (byte)PathPointType.Bezier,
                (byte)PathPointType.Bezier,
                (byte)PathPointType.Bezier,
                (byte)PathPointType.Line,
                (byte)PathPointType.Line
            });
            myPath.AddPath(myPath3, false);
            
            gp.AddPath(myPath, false);

            return gp;
        }
        private GraphicsPath ModifyPathExample(GraphicsPath gp)
        {

            // Get the total number of points for input path,
            // and the arrays of the points and types.
            int inPathPointCount = gp.PointCount;
            PointF[] inPathPoints = gp.PathPoints;
            byte[] inPathTypes = gp.PathTypes;
            
            // Init output path for additional pts
            int numPtsAdding = 2;
            PointF[] pathPoints = new PointF[inPathPointCount + numPtsAdding];
            byte[] pathTypes = new byte[inPathPointCount + numPtsAdding];

            // Loop over pts
            for (int i = 0; i < inPathPointCount + numPtsAdding; i++)
            {
                if (i < inPathPointCount)
                {
                    pathPoints[i] = gp.PathPoints[i];
                    pathTypes[i] = (byte)PathPointType.Line;
                }
                else if (i >= inPathPointCount)
                {
                    pathPoints[i] = gp.PathPoints[i - numPtsAdding];
                    pathTypes[i] = (byte)PathPointType.Line; // .Start, .Bezier, .CloseSubpath, etc.
                }
                else
                {
                }
            }
            GraphicsPath myPath4 = new GraphicsPath(pathPoints,pathTypes);
            return myPath4;
        }
        private GraphicsPath ShowOctaCenter(GraphicsPath gp)
        {
            // Get the total number of points for input path,
            // and the arrays of the points and types.
            int inPathPointCount = gp.PointCount;
            PointF[] inPathPoints = gp.PathPoints;
            byte[] inPathTypes = gp.PathTypes;

            // Init output path for additional pts
            int numPtsAdding = 1;
            PointF[] pathPoints = new PointF[inPathPointCount + numPtsAdding];
            byte[] pathTypes = new byte[inPathPointCount + numPtsAdding];

            // Loop over pts
            for (int i = 0; i < inPathPointCount + numPtsAdding; i++)
            {
                if (i >= inPathPointCount)
                {
                    pathPoints[i] = GetOctaCenter(gp.PathPoints);
                    pathTypes[i] = (byte)PathPointType.Line;
                }
                else if (i > inPathPointCount)
                {
                    //pathPoints[i] = gp.PathPoints[i - numPtsAdding];
                    //pathTypes[i] = (byte)PathPointType.Line; // .Start, .Bezier, .CloseSubpath, etc.
                }
                else
                {
                    pathPoints[i] = inPathPoints[i];
                    pathTypes[i] = inPathTypes[i];
                }
            }
            GraphicsPath myPath4 = new GraphicsPath(pathPoints, pathTypes);
            return myPath4;
        }
        private PointF GetOctaCenter(PointF[] pp)
        {
            //Debug.Write(string.Format("ptZero: x={0},y={1}", p0.X, p0.Y));
            //Debug.Write(string.Format(" ptSix: x={0},y={1}", p6.X, p6.Y));
            float meanX = 0;
            float meanY = 0;
            foreach (PointF p in pp)
            {
                meanX += p.X;
                meanY += p.Y;
            }
            meanX /= pp.Length;
            meanY /= pp.Length;
            PointF pCtr = new PointF(meanX,meanY);
            return pCtr;
        }
        public void AddPointToGraphicsPath(GraphicsPath gp)
        {
            // First let's see what's there before adding any pts
            ShowSubPathInfo(gp);

            // Let's see about growing an array
            int gpPointCount = gp.PointCount;
            PointF[] gpPathPoints = gp.PathPoints;
            byte[] gpPathTypes = gp.PathTypes;

            ArrayList result = new ArrayList();
            {
                //do stuff to fill the result
            }
            //return (PointF[])result.ToArray(typeof(PointF[]));

            gp.PathPoints[gpPointCount].X = 77;
            gp.PathPoints[gpPointCount].Y = 99;
            gp.PathTypes[gpPointCount] = (byte)0;

            Debug.Write(string.Format("Last x-value of gp is {0}", gpPathPoints[gpPointCount].X));

        }
        public void TranslateRotate(GraphicsPath gp)
        {
            Matrix translateMatrix = new Matrix();
            translateMatrix.Translate(100, 0);
            gp.Transform(translateMatrix);

            Matrix rotateMatrix = new Matrix();
            rotateMatrix.RotateAt(45, gp.PathPoints[0], MatrixOrder.Append);
            gp.Transform(rotateMatrix);
        }
    }
}