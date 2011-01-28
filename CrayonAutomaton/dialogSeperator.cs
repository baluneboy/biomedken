using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace CrayonAutomaton {
    public partial class dialogSeperator : UserControl {
        public dialogSeperator() {
            InitializeComponent();
            Text = Name;
        }

        override public string Text {
            get { return mainLabel.Text; }
            set { mainLabel.Text = value; }
        }
    }
}
