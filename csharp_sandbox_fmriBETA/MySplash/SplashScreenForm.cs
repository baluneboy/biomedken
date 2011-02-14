using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace MySplash
{
    public partial class SplashScreenForm : Form
    {
        delegate void StringParameterDelegate(string Text);
        delegate void StringParameterWithStatusDelegate(string Text, TypeOfMessage tom);
        delegate void SplashShowCloseDelegate();

        
        // To ensure splash screen is closed using the API and not by keyboard or any other things
        
        bool CloseSplashScreenFlag = false;

        
        // Base constructor
        
        public SplashScreenForm()
        {
            InitializeComponent();
            this.label1.Parent = this.pictureBox1;
            this.label1.BackColor = Color.Transparent;
            label1.ForeColor = Color.Green;

            //this.progressBar1.Parent = this.pictureBox1;
            //this.progressBar1.BackColor = Color.Transparent;

            progressBar1.Show();
        }

        
        // Displays the splashscreen
        
        public void ShowSplashScreen()
        {
            if (InvokeRequired)
            {
                // We're not in the UI thread, so we need to call BeginInvoke
                BeginInvoke(new SplashShowCloseDelegate(ShowSplashScreen));
                return;
            }
            this.Show();
            Application.Run(this);
        }

        
        // Closes the SplashScreen
        
        public void CloseSplashScreen()
        {
            if (InvokeRequired)
            {
                // We're not in the UI thread, so we need to call BeginInvoke
                BeginInvoke(new SplashShowCloseDelegate(CloseSplashScreen));
                return;
            }
            CloseSplashScreenFlag = true;
            this.Close();
        }

        
        // Update text in default green color of success message

        public void UdpateStatusText(string Text)
        {
            if (InvokeRequired)
            {
                // We're not in the UI thread, so we need to call BeginInvoke
                BeginInvoke(new StringParameterDelegate(UdpateStatusText), new object[] { Text });
                return;
            }
            // Must be on the UI thread if we've got this far
            label1.ForeColor = Color.Green;
            label1.Text = Text;
        }


        
        // Update text with message color defined as green/yellow/red/ for success/warning/failure

        public void UdpateStatusTextWithStatus(string Text, TypeOfMessage tom)
        {
            if (InvokeRequired)
            {
                // We're not in the UI thread, so we need to call BeginInvoke
                BeginInvoke(new StringParameterWithStatusDelegate(UdpateStatusTextWithStatus), new object[] { Text, tom });
                return;
            }
            // Must be on the UI thread if we've got this far
            switch (tom)
            {
                case TypeOfMessage.Error:
                    label1.ForeColor = Color.Red;
                    break;
                case TypeOfMessage.Warning:
                    label1.ForeColor = Color.Blue;
                    break;
                case TypeOfMessage.Success:
                    label1.ForeColor = Color.Green;
                    break;
            }
            label1.Text = Text;

        }

        
        // Prevents the closing of form other than by calling the CloseSplashScreen function

        private void SplashForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (CloseSplashScreenFlag == false)
                e.Cancel = true;
        }
    }
}
