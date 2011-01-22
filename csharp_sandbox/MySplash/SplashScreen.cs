using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace MySplash
{
    
    // Defined types of messages: Success/Warning/Error.
    
    public enum TypeOfMessage
    {
        Success,
        Warning,
        Error,
    }
    
    // Initiate instance of SplashScreen
    
    public static class SplashScreen
    {
        static SplashScreenForm sf = null;

        
        // Displays the splashscreen
        
        public static void ShowSplashScreen()
        {
            if (sf == null)
            {
                sf = new SplashScreenForm();
                sf.ShowSplashScreen();
            }
        }

        
        // Closes the SplashScreen
        
        public static void CloseSplashScreen()
        {
            if (sf != null)
            {
                sf.CloseSplashScreen();
                sf = null;
            }
        }

        
        // Update text in default green color of success message
        
        public static void UdpateStatusText(string Text)
        {
            if (sf != null)
                sf.UdpateStatusText(Text);

        }
        
        
        // Update text with message color defined as green/yellow/red/ for success/warning/failure
        
        public static void UdpateStatusTextWithStatus(string Text,TypeOfMessage tom)
        {
            
            if (sf != null)
                sf.UdpateStatusTextWithStatus(Text, tom);
        }
    }

}
