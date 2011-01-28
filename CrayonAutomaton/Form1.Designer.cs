namespace CrayonAutomaton {
    partial class mainForm {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing) {
            if (disposing && (components != null)) {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent() {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(mainForm));
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.saveToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.loadToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.addPathFromFileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator7 = new System.Windows.Forms.ToolStripSeparator();
            this.saveImageAsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.editMenu = new System.Windows.Forms.ToolStripMenuItem();
            this.runWaitsForToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.automaticallyStartNewFigureToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.canvasToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.pasteClipboardToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.clearBackgroundToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.changeSizeToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator6 = new System.Windows.Forms.ToolStripSeparator();
            this.showNodeRectanglesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.detectedHoveredNodesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator5 = new System.Windows.Forms.ToolStripSeparator();
            this.displayGridToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.snapToGridToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.changeGridSizeToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.debugToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.showDebugToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.drawToolStrip = new System.Windows.Forms.ToolStrip();
            this.toolStripSeparator4 = new System.Windows.Forms.ToolStripSeparator();
            this.startFigureStripButton = new System.Windows.Forms.ToolStripButton();
            this.closePathStripButton = new System.Windows.Forms.ToolStripButton();
            this.closeAllStripButton = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.runStripButton = new System.Windows.Forms.ToolStripButton();
            this.clearStripButton1 = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator3 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripLabel1 = new System.Windows.Forms.ToolStripLabel();
            this.perMovePauseTextBox = new System.Windows.Forms.ToolStripTextBox();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripLabel2 = new System.Windows.Forms.ToolStripLabel();
            this.runPauseTextBox = new System.Windows.Forms.ToolStripTextBox();
            this.panel1 = new System.Windows.Forms.Panel();
            this.statusStrip = new System.Windows.Forms.StatusStrip();
            this.mousePosStatusLabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.nodeCountStatusLabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.changedStatusLabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.levelBox = new System.Windows.Forms.PictureBox();
            this.freeDrawResolutionTimer = new System.Windows.Forms.Timer(this.components);
            this.hoveredNodesTimer = new System.Windows.Forms.Timer(this.components);
            this.menuStrip1.SuspendLayout();
            this.drawToolStrip.SuspendLayout();
            this.panel1.SuspendLayout();
            this.statusStrip.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.levelBox)).BeginInit();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.editMenu,
            this.canvasToolStripMenuItem,
            this.debugToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(798, 24);
            this.menuStrip1.TabIndex = 0;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.saveToolStripMenuItem,
            this.loadToolStripMenuItem,
            this.addPathFromFileToolStripMenuItem,
            this.toolStripSeparator7,
            this.saveImageAsToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(35, 20);
            this.fileToolStripMenuItem.Text = "File";
            // 
            // saveToolStripMenuItem
            // 
            this.saveToolStripMenuItem.Name = "saveToolStripMenuItem";
            this.saveToolStripMenuItem.Size = new System.Drawing.Size(183, 22);
            this.saveToolStripMenuItem.Text = "Save...";
            this.saveToolStripMenuItem.ToolTipText = "Save current work";
            this.saveToolStripMenuItem.Click += new System.EventHandler(this.saveToolStripMenuItem_Click);
            // 
            // loadToolStripMenuItem
            // 
            this.loadToolStripMenuItem.Name = "loadToolStripMenuItem";
            this.loadToolStripMenuItem.Size = new System.Drawing.Size(183, 22);
            this.loadToolStripMenuItem.Text = "Load...";
            this.loadToolStripMenuItem.ToolTipText = "Loads a path, overwriting all existing data!";
            this.loadToolStripMenuItem.Click += new System.EventHandler(this.loadToolStripMenuItem_Click);
            // 
            // addPathFromFileToolStripMenuItem
            // 
            this.addPathFromFileToolStripMenuItem.Name = "addPathFromFileToolStripMenuItem";
            this.addPathFromFileToolStripMenuItem.Size = new System.Drawing.Size(183, 22);
            this.addPathFromFileToolStripMenuItem.Text = "Add path from file...";
            this.addPathFromFileToolStripMenuItem.ToolTipText = "Adds a path to your existing project";
            this.addPathFromFileToolStripMenuItem.Click += new System.EventHandler(this.addPathFromFileToolStripMenuItem_Click);
            // 
            // toolStripSeparator7
            // 
            this.toolStripSeparator7.Name = "toolStripSeparator7";
            this.toolStripSeparator7.Size = new System.Drawing.Size(180, 6);
            // 
            // saveImageAsToolStripMenuItem
            // 
            this.saveImageAsToolStripMenuItem.Name = "saveImageAsToolStripMenuItem";
            this.saveImageAsToolStripMenuItem.Size = new System.Drawing.Size(183, 22);
            this.saveImageAsToolStripMenuItem.Text = "Export Image...";
            this.saveImageAsToolStripMenuItem.Click += new System.EventHandler(this.saveImageAsToolStripMenuItem_Click);
            // 
            // editMenu
            // 
            this.editMenu.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.runWaitsForToolStripMenuItem,
            this.automaticallyStartNewFigureToolStripMenuItem});
            this.editMenu.Name = "editMenu";
            this.editMenu.Size = new System.Drawing.Size(56, 20);
            this.editMenu.Text = "Options";
            // 
            // runWaitsForToolStripMenuItem
            // 
            this.runWaitsForToolStripMenuItem.Name = "runWaitsForToolStripMenuItem";
            this.runWaitsForToolStripMenuItem.Size = new System.Drawing.Size(229, 22);
            this.runWaitsForToolStripMenuItem.Text = "Run waits for deactivate";
            this.runWaitsForToolStripMenuItem.Click += new System.EventHandler(this.runWaitsForToolStripMenuItem_Click);
            // 
            // automaticallyStartNewFigureToolStripMenuItem
            // 
            this.automaticallyStartNewFigureToolStripMenuItem.Name = "automaticallyStartNewFigureToolStripMenuItem";
            this.automaticallyStartNewFigureToolStripMenuItem.Size = new System.Drawing.Size(229, 22);
            this.automaticallyStartNewFigureToolStripMenuItem.Text = "Automatically start new figure";
            this.automaticallyStartNewFigureToolStripMenuItem.Click += new System.EventHandler(this.automaticallyStartNewFigureToolStripMenuItem_Click);
            // 
            // canvasToolStripMenuItem
            // 
            this.canvasToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.pasteClipboardToolStripMenuItem,
            this.clearBackgroundToolStripMenuItem,
            this.changeSizeToolStripMenuItem,
            this.toolStripSeparator6,
            this.showNodeRectanglesToolStripMenuItem,
            this.detectedHoveredNodesToolStripMenuItem,
            this.toolStripSeparator5,
            this.displayGridToolStripMenuItem,
            this.snapToGridToolStripMenuItem,
            this.changeGridSizeToolStripMenuItem});
            this.canvasToolStripMenuItem.Name = "canvasToolStripMenuItem";
            this.canvasToolStripMenuItem.Size = new System.Drawing.Size(55, 20);
            this.canvasToolStripMenuItem.Text = "Canvas";
            // 
            // pasteClipboardToolStripMenuItem
            // 
            this.pasteClipboardToolStripMenuItem.Name = "pasteClipboardToolStripMenuItem";
            this.pasteClipboardToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.V)));
            this.pasteClipboardToolStripMenuItem.Size = new System.Drawing.Size(304, 22);
            this.pasteClipboardToolStripMenuItem.Text = "Paste Clipboard as Background Image";
            this.pasteClipboardToolStripMenuItem.Click += new System.EventHandler(this.pasteClipboardToolStripMenuItem_Click_1);
            // 
            // clearBackgroundToolStripMenuItem
            // 
            this.clearBackgroundToolStripMenuItem.Name = "clearBackgroundToolStripMenuItem";
            this.clearBackgroundToolStripMenuItem.Size = new System.Drawing.Size(304, 22);
            this.clearBackgroundToolStripMenuItem.Text = "Clear Background";
            this.clearBackgroundToolStripMenuItem.Click += new System.EventHandler(this.clearBackgroundToolStripMenuItem_Click);
            // 
            // changeSizeToolStripMenuItem
            // 
            this.changeSizeToolStripMenuItem.Name = "changeSizeToolStripMenuItem";
            this.changeSizeToolStripMenuItem.Size = new System.Drawing.Size(304, 22);
            this.changeSizeToolStripMenuItem.Text = "Change Canvas Size...";
            this.changeSizeToolStripMenuItem.Click += new System.EventHandler(this.changeSizeToolStripMenuItem_Click);
            // 
            // toolStripSeparator6
            // 
            this.toolStripSeparator6.Name = "toolStripSeparator6";
            this.toolStripSeparator6.Size = new System.Drawing.Size(301, 6);
            // 
            // showNodeRectanglesToolStripMenuItem
            // 
            this.showNodeRectanglesToolStripMenuItem.Name = "showNodeRectanglesToolStripMenuItem";
            this.showNodeRectanglesToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.N)));
            this.showNodeRectanglesToolStripMenuItem.Size = new System.Drawing.Size(304, 22);
            this.showNodeRectanglesToolStripMenuItem.Text = "Show Node Rectangles";
            this.showNodeRectanglesToolStripMenuItem.Click += new System.EventHandler(this.showNodeRectanglesToolStripMenuItem_Click);
            // 
            // detectedHoveredNodesToolStripMenuItem
            // 
            this.detectedHoveredNodesToolStripMenuItem.Name = "detectedHoveredNodesToolStripMenuItem";
            this.detectedHoveredNodesToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.H)));
            this.detectedHoveredNodesToolStripMenuItem.Size = new System.Drawing.Size(304, 22);
            this.detectedHoveredNodesToolStripMenuItem.Text = "Detected Hovered Nodes";
            this.detectedHoveredNodesToolStripMenuItem.Click += new System.EventHandler(this.detectedHoveredNodesToolStripMenuItem_Click);
            // 
            // toolStripSeparator5
            // 
            this.toolStripSeparator5.Name = "toolStripSeparator5";
            this.toolStripSeparator5.Size = new System.Drawing.Size(301, 6);
            // 
            // displayGridToolStripMenuItem
            // 
            this.displayGridToolStripMenuItem.Name = "displayGridToolStripMenuItem";
            this.displayGridToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.G)));
            this.displayGridToolStripMenuItem.Size = new System.Drawing.Size(304, 22);
            this.displayGridToolStripMenuItem.Text = "Display Grid";
            this.displayGridToolStripMenuItem.Click += new System.EventHandler(this.displayGridToolStripMenuItem_Click);
            // 
            // snapToGridToolStripMenuItem
            // 
            this.snapToGridToolStripMenuItem.Name = "snapToGridToolStripMenuItem";
            this.snapToGridToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S)));
            this.snapToGridToolStripMenuItem.Size = new System.Drawing.Size(304, 22);
            this.snapToGridToolStripMenuItem.Text = "Snap to Grid";
            this.snapToGridToolStripMenuItem.Click += new System.EventHandler(this.snapToGridToolStripMenuItem_Click);
            // 
            // changeGridSizeToolStripMenuItem
            // 
            this.changeGridSizeToolStripMenuItem.Name = "changeGridSizeToolStripMenuItem";
            this.changeGridSizeToolStripMenuItem.Size = new System.Drawing.Size(304, 22);
            this.changeGridSizeToolStripMenuItem.Text = "Change Grid Size...";
            this.changeGridSizeToolStripMenuItem.Click += new System.EventHandler(this.changeGridSizeToolStripMenuItem_Click);
            // 
            // debugToolStripMenuItem
            // 
            this.debugToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.showDebugToolStripMenuItem});
            this.debugToolStripMenuItem.Name = "debugToolStripMenuItem";
            this.debugToolStripMenuItem.Size = new System.Drawing.Size(50, 20);
            this.debugToolStripMenuItem.Text = "Debug";
            // 
            // showDebugToolStripMenuItem
            // 
            this.showDebugToolStripMenuItem.Name = "showDebugToolStripMenuItem";
            this.showDebugToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.D)));
            this.showDebugToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.showDebugToolStripMenuItem.Text = "ShowDebug";
            this.showDebugToolStripMenuItem.Click += new System.EventHandler(this.showDebugToolStripMenuItem_Click);
            // 
            // drawToolStrip
            // 
            this.drawToolStrip.GripStyle = System.Windows.Forms.ToolStripGripStyle.Hidden;
            this.drawToolStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripSeparator4,
            this.startFigureStripButton,
            this.closePathStripButton,
            this.closeAllStripButton,
            this.toolStripSeparator2,
            this.runStripButton,
            this.clearStripButton1,
            this.toolStripSeparator3,
            this.toolStripLabel1,
            this.perMovePauseTextBox,
            this.toolStripSeparator1,
            this.toolStripLabel2,
            this.runPauseTextBox});
            this.drawToolStrip.Location = new System.Drawing.Point(0, 24);
            this.drawToolStrip.Name = "drawToolStrip";
            this.drawToolStrip.Size = new System.Drawing.Size(798, 25);
            this.drawToolStrip.TabIndex = 1;
            this.drawToolStrip.Text = "toolStrip1";
            // 
            // toolStripSeparator4
            // 
            this.toolStripSeparator4.Name = "toolStripSeparator4";
            this.toolStripSeparator4.Size = new System.Drawing.Size(6, 25);
            // 
            // startFigureStripButton
            // 
            this.startFigureStripButton.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.startFigureStripButton.Image = ((System.Drawing.Image)(resources.GetObject("startFigureStripButton.Image")));
            this.startFigureStripButton.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.startFigureStripButton.Name = "startFigureStripButton";
            this.startFigureStripButton.Size = new System.Drawing.Size(68, 22);
            this.startFigureStripButton.Text = "Start Figure";
            this.startFigureStripButton.Click += new System.EventHandler(this.startFigureStripButton_Click);
            // 
            // closePathStripButton
            // 
            this.closePathStripButton.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.closePathStripButton.Image = ((System.Drawing.Image)(resources.GetObject("closePathStripButton.Image")));
            this.closePathStripButton.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.closePathStripButton.Name = "closePathStripButton";
            this.closePathStripButton.Size = new System.Drawing.Size(62, 22);
            this.closePathStripButton.Text = "Close Path";
            this.closePathStripButton.ToolTipText = "Close current path";
            this.closePathStripButton.Click += new System.EventHandler(this.closePathStripButton_Click);
            // 
            // closeAllStripButton
            // 
            this.closeAllStripButton.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.closeAllStripButton.Image = ((System.Drawing.Image)(resources.GetObject("closeAllStripButton.Image")));
            this.closeAllStripButton.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.closeAllStripButton.Name = "closeAllStripButton";
            this.closeAllStripButton.Size = new System.Drawing.Size(51, 22);
            this.closeAllStripButton.Text = "Close All";
            this.closeAllStripButton.ToolTipText = "Close all open paths";
            this.closeAllStripButton.Click += new System.EventHandler(this.closeAllStripButton_Click);
            // 
            // toolStripSeparator2
            // 
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(6, 25);
            // 
            // runStripButton
            // 
            this.runStripButton.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.runStripButton.Image = ((System.Drawing.Image)(resources.GetObject("runStripButton.Image")));
            this.runStripButton.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.runStripButton.Name = "runStripButton";
            this.runStripButton.Size = new System.Drawing.Size(36, 22);
            this.runStripButton.Text = "RUN!";
            this.runStripButton.ToolTipText = "Run your creation!";
            this.runStripButton.Click += new System.EventHandler(this.runStripButton_Click);
            // 
            // clearStripButton1
            // 
            this.clearStripButton1.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.clearStripButton1.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.clearStripButton1.Name = "clearStripButton1";
            this.clearStripButton1.Size = new System.Drawing.Size(43, 22);
            this.clearStripButton1.Text = "CLEAR";
            this.clearStripButton1.ToolTipText = "Clear ALL objects drawn to canvas";
            this.clearStripButton1.Click += new System.EventHandler(this.clearStripButton1_Click);
            // 
            // toolStripSeparator3
            // 
            this.toolStripSeparator3.Name = "toolStripSeparator3";
            this.toolStripSeparator3.Size = new System.Drawing.Size(6, 25);
            // 
            // toolStripLabel1
            // 
            this.toolStripLabel1.Name = "toolStripLabel1";
            this.toolStripLabel1.Size = new System.Drawing.Size(84, 22);
            this.toolStripLabel1.Text = "Per Move Pause";
            // 
            // perMovePauseTextBox
            // 
            this.perMovePauseTextBox.Name = "perMovePauseTextBox";
            this.perMovePauseTextBox.Size = new System.Drawing.Size(100, 25);
            this.perMovePauseTextBox.ToolTipText = "Pause between each mouse movement";
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(6, 25);
            // 
            // toolStripLabel2
            // 
            this.toolStripLabel2.Name = "toolStripLabel2";
            this.toolStripLabel2.Size = new System.Drawing.Size(58, 22);
            this.toolStripLabel2.Text = "Run Pause";
            // 
            // runPauseTextBox
            // 
            this.runPauseTextBox.Name = "runPauseTextBox";
            this.runPauseTextBox.Size = new System.Drawing.Size(100, 25);
            this.runPauseTextBox.ToolTipText = "Pause before the vectors begin to be drawn";
            // 
            // panel1
            // 
            this.panel1.AutoScroll = true;
            this.panel1.Controls.Add(this.statusStrip);
            this.panel1.Controls.Add(this.levelBox);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel1.Location = new System.Drawing.Point(0, 49);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(798, 391);
            this.panel1.TabIndex = 3;
            // 
            // statusStrip
            // 
            this.statusStrip.GripStyle = System.Windows.Forms.ToolStripGripStyle.Visible;
            this.statusStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mousePosStatusLabel,
            this.nodeCountStatusLabel,
            this.changedStatusLabel});
            this.statusStrip.Location = new System.Drawing.Point(0, 720);
            this.statusStrip.Name = "statusStrip";
            this.statusStrip.Size = new System.Drawing.Size(1280, 22);
            this.statusStrip.TabIndex = 4;
            this.statusStrip.Text = "statusStrip1";
            // 
            // mousePosStatusLabel
            // 
            this.mousePosStatusLabel.Name = "mousePosStatusLabel";
            this.mousePosStatusLabel.Size = new System.Drawing.Size(0, 17);
            // 
            // nodeCountStatusLabel
            // 
            this.nodeCountStatusLabel.Name = "nodeCountStatusLabel";
            this.nodeCountStatusLabel.Size = new System.Drawing.Size(1265, 17);
            this.nodeCountStatusLabel.Spring = true;
            this.nodeCountStatusLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // changedStatusLabel
            // 
            this.changedStatusLabel.Name = "changedStatusLabel";
            this.changedStatusLabel.Size = new System.Drawing.Size(0, 17);
            // 
            // levelBox
            // 
            this.levelBox.BackColor = System.Drawing.Color.White;
            this.levelBox.Location = new System.Drawing.Point(0, 0);
            this.levelBox.Name = "levelBox";
            this.levelBox.Size = new System.Drawing.Size(1280, 720);
            this.levelBox.TabIndex = 3;
            this.levelBox.TabStop = false;
            // 
            // freeDrawResolutionTimer
            // 
            this.freeDrawResolutionTimer.Enabled = true;
            this.freeDrawResolutionTimer.Tick += new System.EventHandler(this.freeDrawResolutionTimer_Tick);
            // 
            // hoveredNodesTimer
            // 
            this.hoveredNodesTimer.Tick += new System.EventHandler(this.hoveredNodesTimer_Tick);
            // 
            // mainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(798, 440);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.drawToolStrip);
            this.Controls.Add(this.menuStrip1);
            this.DoubleBuffered = true;
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "mainForm";
            this.Text = "Crayon Automaton";
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.drawToolStrip.ResumeLayout(false);
            this.drawToolStrip.PerformLayout();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.statusStrip.ResumeLayout(false);
            this.statusStrip.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.levelBox)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem editMenu;
        private System.Windows.Forms.ToolStrip drawToolStrip;
        private System.Windows.Forms.ToolStripLabel toolStripLabel1;
        private System.Windows.Forms.ToolStripTextBox perMovePauseTextBox;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripLabel toolStripLabel2;
        private System.Windows.Forms.ToolStripTextBox runPauseTextBox;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator3;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
        private System.Windows.Forms.ToolStripButton clearStripButton1;
        private System.Windows.Forms.ToolStripMenuItem runWaitsForToolStripMenuItem;
        private System.Windows.Forms.ToolStripButton runStripButton;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.PictureBox levelBox;
        private System.Windows.Forms.ToolStripButton closePathStripButton;
        private System.Windows.Forms.ToolStripButton closeAllStripButton;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator4;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem saveToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem loadToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem addPathFromFileToolStripMenuItem;
        private System.Windows.Forms.Timer freeDrawResolutionTimer;
        private System.Windows.Forms.StatusStrip statusStrip;
        private System.Windows.Forms.ToolStripStatusLabel mousePosStatusLabel;
        private System.Windows.Forms.ToolStripMenuItem canvasToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem pasteClipboardToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem showNodeRectanglesToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem clearBackgroundToolStripMenuItem;
        private System.Windows.Forms.ToolStripButton startFigureStripButton;
        private System.Windows.Forms.ToolStripMenuItem changeSizeToolStripMenuItem;
        private System.Windows.Forms.ToolStripStatusLabel nodeCountStatusLabel;
        private System.Windows.Forms.ToolStripStatusLabel changedStatusLabel;
        private System.Windows.Forms.Timer hoveredNodesTimer;
        private System.Windows.Forms.ToolStripMenuItem detectedHoveredNodesToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem automaticallyStartNewFigureToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator5;
        private System.Windows.Forms.ToolStripMenuItem displayGridToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem snapToGridToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator6;
        private System.Windows.Forms.ToolStripMenuItem changeGridSizeToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator7;
        private System.Windows.Forms.ToolStripMenuItem saveImageAsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem debugToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem showDebugToolStripMenuItem;
    }
}

