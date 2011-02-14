using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace CrayonAutomaton {
    public partial class enterSizeDialog : Form {
        public Size EnterSize { get; set; }
        public enterSizeDialog(Size currentSize) {
            InitializeComponent();
            widthUpDown.Value = currentSize.Width;
            heightUpDown.Value = currentSize.Height;
            currentWidthLabel.Text = currentSize.Width.ToString();
            currentHeightLabel.Text = currentSize.Height.ToString();
        }

        private void setButton_Click(object sender, EventArgs e) {
            DialogResult = DialogResult.OK;
            EnterSize = new Size((int)widthUpDown.Value, (int)heightUpDown.Value);
            Dispose();
        }

        private void cancelButton_Click(object sender, EventArgs e) {
            DialogResult = DialogResult.Cancel;
            Dispose();
        }

        private void enterSizeDialog_Load(object sender, EventArgs e) {

        }
    }
}
