using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace CrayonAutomaton {
    public partial class enterTextDialog : Form {
        public delegate void PreviewUpdateEventHandler(enterTextDialog dialog);
        public event PreviewUpdateEventHandler PreviewUpdateEvent;

        public Font SelectedFont { get; set; }
        public string EnteredText {
            get { return usersText.Text; }
        }

        public enterTextDialog() {
            InitializeComponent();
            updateFont(new Font(this.Font, FontStyle.Regular));
            usersText.TextChanged += new EventHandler(usersText_TextChanged);
        }

        void usersText_TextChanged(object sender, EventArgs e) {
            update();
        }

        private void selectFontButton_Click(object sender, EventArgs e) {
            FontDialog fontDialog = new FontDialog();
            fontDialog.Font = SelectedFont;
            if (fontDialog.ShowDialog() == DialogResult.OK)
                updateFont(fontDialog.Font);
        }

        void updateFont(Font font) {
            SelectedFont = font;
            fontLabel.Text = font.ToString();
            update();
        }

        void update() {
            if ((PreviewUpdateEvent != null) && (previewCheckBox.Checked))
                PreviewUpdateEvent(this);
        }

        private void symbolButton_Click(object sender, EventArgs e) {
            textSymbol symbolDialog = new textSymbol(SelectedFont);
            if (symbolDialog.ShowDialog() == DialogResult.OK)
                usersText.Text += symbolDialog.Symbols;
        }

        private void previewCheckBox_CheckedChanged(object sender, EventArgs e) {
            update();
        }
    }
}
