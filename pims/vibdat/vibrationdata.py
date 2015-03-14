#!/usr/bin/env python
###############################################################################
# program: vibrationdata.py
# author: Tom Irvine
# Email: tom@vibrationdata.com
# version: 5.4
# date: October 14, 2014
# description:  multi-function signal analysis program
#
###############################################################################

from __future__ import print_function

import sys

if sys.version_info[0] == 2:
    import Tkinter as tk
           
if sys.version_info[0] == 3:   
    import tkinter as tk 



import matplotlib.pyplot as plt


import webbrowser

###############################################################################

def quit(root):
    root.destroy()


def visitWiki():
    webbrowser.open('http://vibrationdata.com/python-wiki/index.php?title=Main_Page')

###############################################################################

def SignalAnalysisWindow():

    plt.close("all") 
  
    win = tk.Toplevel()
    
    n=int(Lb1.curselection()[0])   

    m=0 

    if(n==m):
        from vb_statistics_gui import vb_statistics        
        vb_statistics(win)
    m=m+1
    
    if(n==m):
        from vb_trend_removal_scaling_gui import vb_trend_removal_scaling        
        vb_trend_removal_scaling(win)
    m=m+1    
        
    if(n==m):
        from vb_various_filters_gui import vb_various_filters        
        vb_various_filters(win)
    m=m+1       
        
    if(n==m):
        from vb_fourier_gui import vb_Fourier        
        vb_Fourier(win)
    m=m+1
        
    if(n==m): 
        from vb_fft_gui import vb_FFT        
        vb_FFT(win)
    m=m+1
        
    if(n==m): 
        from vb_waterfall_fft_gui import vb_waterfall_FFT        
        vb_waterfall_FFT(win)       
    m=m+1
        
    if(n==m):
        from vb_psd_gui import vb_PSD         
        vb_PSD(win)   
    m=m+1
        
    if(n==m):
        from vb_sdof_response_time_domain_gui import vb_sdof_response_time_domain         
        vb_sdof_response_time_domain(win)
    m=m+1
        
    if(n==m):
        from vb_srs_gui import vb_SRS         
        vb_SRS(win)
    m=m+1
        
    if(n==m):
        from vb_rainflow_gui import vb_rainflow         
        vb_rainflow(win)    
    m=m+1
                
    if(n==m):
        from vb_differentiate_gui import vb_differentiate         
        vb_differentiate(win)  
    m=m+1
        
    if(n==m):
        from vb_integrate_gui import vb_integrate         
        vb_integrate(win) 
    m=m+1
    
    if(n==m):
        from vb_autocorrelation_gui import vb_autocorrelation         
        vb_autocorrelation(win)             
    m=m+1 

    if(n==m):
        from vb_cross_correlation_gui import vb_cross_correlation         
        vb_cross_correlation(win)             
    m=m+1 
    
    if(n==m):
        from vb_cepstrum_gui import vb_cepstrum         
        vb_cepstrum(win)             
    m=m+1     
    
    if(n==m):
        from vb_spl_gui import vb_SPL         
        vb_SPL(win)             
    m=m+1
        
    if(n==m):
        from vb_sine_curvefit_gui import vb_sine_curvefit         
        vb_sine_curvefit(win)             
    m=m+1       
    
    if(n==m):
        from vb_tvfa_gui import vb_tvfa         
        vb_tvfa(win)             
    m=m+1     
    
###############################################################################
    
def PSDAnalysisWindow():

    plt.close("all")  
    
    win = tk.Toplevel()
    
    n=int(Lb3.curselection()[0])  
    
    m=0 

    if(n==m):
        from vb_psd_rms_gui import vb_psd_rms        
        vb_psd_rms(win)         
        pass
    
    m=m+1   

    if(n==m):
        from vb_psd_octave_gui import vb_psd_octave        
        vb_psd_octave(win)         
        pass
    
    m=m+1   

    if(n==m):
        from vb_sdof_base_psd_gui import vb_sdof_base_psd        
        vb_sdof_base_psd(win)         
        pass
    
    m=m+1  

    if(n==m):
        from vb_vrs_gui import vb_VRS        
        vb_VRS(win)         
        pass
    
    m=m+1      

    if(n==m):
        from vb_accel_psd_syn_gui import vb_accel_psd_syn        
        vb_accel_psd_syn(win)         
        pass
    
    m=m+1   

    if(n==m):
        from vb_power_trans_gui import vb_power_trans        
        vb_power_trans(win)         
        pass
    
    m=m+1   
    
    if(n==m):
        from vb_envelope_PSD_VRS_gui import vb_envelope_PSD_VRS        
        vb_envelope_PSD_VRS(win)         
        pass
    
    m=m+1      


###############################################################################    

def MiscAnalysisWindow():

    plt.close("all")  
    
    win = tk.Toplevel()
    
    n=int(Lb2.curselection()[0])   

    m=0 

    if(n==m):
        from vb_sine_amplitude_gui import vb_sine_amplitude        
        vb_sine_amplitude(win)         

    m=m+1

    if(n==m):
        from vb_sine_sweep_parameters_gui import vb_sine_sweep_parameters        
        vb_sine_sweep_parameters(win)         

    m=m+1
    
    if(n==m):
        from vb_peak_sigma_random_gui import vb_peak_sigma_random        
        vb_peak_sigma_random(win)   
                
    m=m+1

    if(n==m):
        from vb_classical_base_gui import vb_classical_pulse_base        
        vb_classical_pulse_base(win) 
        
    m=m+1

    if(n==m):
        from vb_steady_gui import vb_steady        
        vb_steady(win)         
        
    m=m+1

    if(n==m):
        from vb_generate_gui import vb_generate        
        vb_generate(win)   
        
    m=m+1

    if(n==m):
        from vb_damping_conversion_gui import vb_damping_conversion        
        vb_damping_conversion(win)  

    m=m+1

    if(n==m):
        from vb_half_power_curvefit_gui import vb_half_power_curvefit        
        vb_half_power_curvefit(win)          
        
    m=m+1  
      
    if(n==m):
        from vb_structural_dynamics_gui import vb_structural_dynamics        
        vb_structural_dynamics(win)           

    m=m+1  
      
    if(n==m):
        from vb_plot_utilities_gui import vb_plot_utilities        
        vb_plot_utilities(win)        

    m=m+1  
     
    if(n==m):
        from vb_signal_editing_gui import vb_signal_editing      
        vb_signal_editing(win)     

    m=m+1  
     
    if(n==m):
        from vb_rotation_gui import vb_rotation      
        vb_rotation(win)              
                 
    m=m+1  
     
    if(n==m):
        from vb_miles_gui import vb_miles      
        vb_miles(win)     

    m=m+1  
     
    if(n==m):
        from vb_statistical_distributions_gui import vb_statistical_distributions      
        vb_statistical_distributions(win)      

    m=m+1  
     
    if(n==m):
        from vb_Doppler_shift_gui import vb_Doppler_shift      
        vb_Doppler_shift(win)               
        
    m=m+1  
     
    if(n==m):
        from vb_dB_calculations_gui import vb_dB_calculations      
        vb_dB_calculations(win)                
 
    m=m+1  
     
    if(n==m):
        from vb_sound_file_editor_gui import vb_sound_file_editor      
        vb_sound_file_editor(win)   
       
        
###############################################################################
    
# create root window

root = tk.Tk()

root.minsize(1060,500)
root.geometry("1160x550")

root.title("vibrationdata.py ver 5.4  by Tom Irvine") 

###############################################################################

crow=1

hwtext1=tk.Label(root,text='Multi-function Signal Analysis Script & More')
hwtext1.grid(row=crow, column=0, columnspan=3, padx=8, pady=7,sticky=tk.W)

crow=crow+1

hwtext1=tk.Label(root,text='Note:  for use within Spyder IDE, set: Run > Configuration > Interpreter > Excecute in an external system terminal')
hwtext1.grid(row=crow, column=0, columnspan=3, padx=8, pady=5,sticky=tk.W)

###############################################################################

crow=crow+1

hwtext2=tk.Label(root,text='Select Signal Analysis')
hwtext2.grid(row=crow, column=0, columnspan=1, padx=8, pady=8)

hwtext2=tk.Label(root,text='Select PSD Analysis')
hwtext2.grid(row=crow, column=1, columnspan=1, padx=8, pady=8)

hwtext3=tk.Label(root,text='Select Miscellaneous Analysis')
hwtext3.grid(row=crow, column=2, columnspan=1, padx=8, pady=8)

###############################################################################

crow=crow+1

Lb1 = tk.Listbox(root,height=19,width=36,exportselection=0)
Lb1.insert(1, "Statistics")
Lb1.insert(2, "Trend Removal & Scaling")
Lb1.insert(3, "Filters, Various")
Lb1.insert(4, "Fourier Transform")
Lb1.insert(5, "FFT")
Lb1.insert(6, "Waterfall FFT")
Lb1.insert(7, "PSD")
Lb1.insert(8, "SDOF Response, Base Input & Force")
Lb1.insert(9, "SRS")
Lb1.insert(10, "Rainflow Cycle Counting")
Lb1.insert(11, "Differentiate")
Lb1.insert(12, "Integrate")
Lb1.insert(13, "Autocorrelation")
Lb1.insert(14, "Cross-correlation")
Lb1.insert(15, "Cepstrum & Auto Cepstrum")
Lb1.insert(16, "Sound Pressure Level")
Lb1.insert(17, "Sine & Damped Sine Curve-fit")
Lb1.insert(18, "Time Varying Freq & Amp")
Lb1.grid(row=crow, column=0, padx=16, pady=4,sticky=tk.NE)
Lb1.select_set(0) 

Lb3 = tk.Listbox(root,height=8,width=37,exportselection=0)
Lb3.insert(1, "Overall RMS")
Lb3.insert(2, "Convert to Octave Format")
Lb3.insert(3, "SDOF Response to Base Input")
Lb3.insert(4, "Vibration Response Spectrum")
Lb3.insert(5, "Acceleration PSD Time History Synthesis")
Lb3.insert(6, "Power Transmissibilty from two PSDs")
Lb3.insert(7, "Envelope PSD via VRS")
Lb3.grid(row=crow, column=1, columnspan=1, padx=8, pady=4,sticky=tk.N)
Lb3.select_set(0)

Lb2 = tk.Listbox(root,height=18,width=48,exportselection=0)
Lb2.insert(1, "Sine Amplitude Conversion")
Lb2.insert(2, "Sine Sweep Parameters")
Lb2.insert(3, "SDOF Response: Peak Sigma for Random Base Input")
Lb2.insert(4, "SDOF Response to Classical Pulse Base Input")
Lb2.insert(5, "SDOF Steady-State Response to Sine Excitation")
Lb2.insert(6, "Generate Signal")
Lb2.insert(7, "Damping Value Conversion")
Lb2.insert(8, "Half-power Bandwidth Curve-fit")
Lb2.insert(9, "Structural Dynamics")
Lb2.insert(10, "Plot Utilities")
Lb2.insert(11, "Signal Editing Utilities")
Lb2.insert(12, "Rotation")
Lb2.insert(13, "Miles Equation")
Lb2.insert(14, "Statistical Distributions")
Lb2.insert(15, "Doppler Shift")
Lb2.insert(16, "dB Calculations for log-log Plots")
Lb2.insert(17, "Sound File Editor")
Lb2.grid(row=crow, column=2, columnspan=3, padx=8, pady=4,sticky=tk.NW)
Lb2.select_set(0)

###############################################################################

crow=crow+1

button1=tk.Button(root, text='Perform Signal Analysis', command=SignalAnalysisWindow)
button1.grid(row=crow, column=0, padx=8, pady=10)
button1.config( height = 2, width = 30 )

button3=tk.Button(root, text='Perform PSD Analysis', command=PSDAnalysisWindow)
button3.grid(row=crow, column=1, padx=8, pady=10)
button3.config( height = 2, width = 20 )

button2=tk.Button(root, text='Perform Miscellaneous Analysis', command=MiscAnalysisWindow)
button2.grid(row=crow, column=2, padx=8, pady=10)
button2.config( height = 2, width = 30 )

button3=tk.Button(root, text='Visit Python Wiki', command=visitWiki)
button3.grid(row=crow, column=3, padx=8, pady=10)
button3.config( height = 2, width = 15 )


button_quit=tk.Button(root, text="Quit", command=lambda root=root:quit(root))
button_quit.config( height = 2, width = 10 )
button_quit.grid(row=crow, column=4, padx=3,pady=10)


###############################################################################

# start event-loop

root.mainloop()
