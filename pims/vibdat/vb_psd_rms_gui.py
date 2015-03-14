########################################################################
# program: vb_psd_rms_gui.py
# author: Tom Irvine
# Email: tom@vibrationdata.com
# version: 1.5
# date: October 16, 2014
# description:  
#              
#  This script calculates the overall level of a PSD.
#
########################################################################

from __future__ import print_function
    
import sys

if sys.version_info[0] == 2:
    print ("Python 2.x")
    import Tkinter as tk
    from tkFileDialog import asksaveasfilename
    from ttk import Treeview
           
if sys.version_info[0] == 3:
    print ("Python 3.x")    
    import tkinter as tk 
    from tkinter.filedialog import asksaveasfilename       
    from tkinter.ttk import Treeview
    

from vb_utilities import read_two_columns_from_dialog

from numpy import array,zeros,log,pi,sqrt,delete

from matplotlib.ticker import ScalarFormatter

import matplotlib.pyplot as plt


###############################################################################

class vb_psd_rms:
    
    def __init__(self,parent):    
        
        self.master=parent        # store the parent
        top = tk.Frame(parent)    # frame for all class widgets
        top.pack(side='top')      # pack frame in parent's window
        
        self.master.minsize(400,500)
        self.master.geometry("550x600")
        self.master.title("vb_psd_rms_gui.py ver 1.5  by Tom Irvine")  


###############################################################################
        
        crow=0
        
        self.hwtext3=tk.Label(top,text='This script calculates the overall level of a PSD.')
        self.hwtext3.grid(row=crow, column=0,columnspan=2, pady=6,sticky=tk.W)        
        
        crow=crow+1

        self.hwtext3=tk.Label(top,text='The input file must have two columns: Freq(Hz) & Accel(G^2/Hz)')
        self.hwtext3.grid(row=crow, column=0,columnspan=2, pady=6,sticky=tk.W)
        
        crow=crow+1    
        
        self.hwtext4=tk.Label(top,text='Select Output Units')
        self.hwtext4.grid(row=crow, column=1,columnspan=1, pady=6,sticky=tk.S)                 
        
        crow=crow+1        
        
        self.button_read = tk.Button(top, text="Read Input File",command=self.read_data)
        self.button_read.config( height = 3, width = 15 )
        self.button_read.grid(row=crow, column=0,columnspan=1,padx=0,pady=2,sticky=tk.N)
        
        self.Lb1 = tk.Listbox(top,height=2,exportselection=0)
        self.Lb1.insert(1, "G, in/sec, in")
        self.Lb1.insert(2, "G, m/sec, mm")
        self.Lb1.grid(row=crow, column=1, pady=2,sticky=tk.N)
        self.Lb1.select_set(0)        
        
        crow=crow+1

        self.hwtext5=tk.Label(top,text='Results, Overall Levels')
        self.hwtext5.grid(row=crow, column=0,columnspan=2, pady=20,sticky=tk.S)        
        
        crow=crow+1          
                
        self.tree = Treeview(top,selectmode="extended",columns=("A","B"),height=6)
        self.tree.grid(row=crow, column=0,columnspan=2, padx=10,pady=1,sticky=tk.N)

        self.tree.heading('#0', text='') 
        self.tree.heading('A', text='Parameter')          
        self.tree.heading('B', text='Value')
        
        self.tree.column('#0',minwidth=0,width=1)
        self.tree.column('A',minwidth=0,width=90, stretch=tk.YES)        
        self.tree.column('B',minwidth=0,width=140)           

        crow=crow+1    
        
        self.hwtext10=tk.Label(top,text='Minimum Plot Freq (Hz)')
        self.hwtext10.grid(row=crow, column=0,columnspan=1, pady=10,sticky=tk.S)    

        self.hwtext11=tk.Label(top,text='Maximum Plot Freq (Hz)')
        self.hwtext11.grid(row=crow, column=1,columnspan=1, pady=10,sticky=tk.S)
         
          
        crow=crow+1

        self.fminr=tk.StringVar()  
        self.fminr.set('')  
        self.fmin_entry=tk.Entry(top, width = 12,textvariable=self.fminr)
        self.fmin_entry.grid(row=crow, column=0,padx=14, pady=1,sticky=tk.N)  
        
        self.fmaxr=tk.StringVar()  
        self.fmaxr.set('')  
        self.fmax_entry=tk.Entry(top, width = 12,textvariable=self.fmaxr)
        self.fmax_entry.grid(row=crow, column=1,padx=14, pady=1,sticky=tk.N)          

        crow=crow+1
        
        root=self.master  
        
        self.button_replot=tk.Button(top, text="Replot", command=self.plot_psd_m)
        self.button_replot.config( height = 2, width = 15 )
        self.button_replot.grid(row=crow, column=0,pady=8,sticky=tk.S)          
        
        self.button_quit=tk.Button(top, text="Quit", command=lambda root=root:quit(root))
        self.button_quit.config( height = 2, width = 15 )
        self.button_quit.grid(row=crow, column=1,pady=8,sticky=tk.S)  


###############################################################################

    def plot_psd_m(self):
        self.plot_psd(self)
        

    def read_data(self):            
        """
        a = frequency column
        b = PSD column
        num = number of coordinates
        slope = slope between coordinate pairs    
        """
        
        map(self.tree.delete, self.tree.get_children())        
        
        print (" ")
        print (" The input file must have two columns: freq(Hz) & accel(G^2/Hz)")

        a,b,num =read_two_columns_from_dialog('Select Input File',self.master)

        print ("\n samples = %d " % num)

        a=array(a)
        b=array(b)
        
        if(a[0]<1.0e-20 or b[0]<1.0e-20):
            a = delete(a, 0)
            b = delete(b, 0)  
            num=num-1
    

        nm1=num-1

        slope =zeros(nm1,'f')


        ra=0

        for i in range (0,int(nm1)):
#
            s=log(b[i+1]/b[i])/log(a[i+1]/a[i])
        
            slope[i]=s
#
            if s < -1.0001 or s > -0.9999:
                ra+= ( b[i+1] * a[i+1]- b[i]*a[i])/( s+1.)
            else:
                ra+= b[i]*a[i]*log( a[i+1]/a[i])

        omega=2*pi*a

        bv=zeros(num,'f') 
        bd=zeros(num,'f') 
        
        for i in range (0,int(num)):         
            bv[i]=b[i]/omega[i]**2
     
        bv=bv*386**2
        rv=0

        for i in range (0,int(nm1)):
#
            s=log(bv[i+1]/bv[i])/log(a[i+1]/a[i])
#
            if s < -1.0001 or s > -0.9999:
                rv+= ( bv[i+1] * a[i+1]- bv[i]*a[i])/( s+1.)
            else:
                rv+= bv[i]*a[i]*log( a[i+1]/a[i])         
         
        
        for i in range (0,int(num)):         
            bd[i]=bv[i]/omega[i]**2
     
        rd=0

        for i in range (0,int(nm1)):
#
            s=log(bd[i+1]/bd[i])/log(a[i+1]/a[i])
#
            if s < -1.0001 or s > -0.9999:
                rd+= ( bd[i+1] * a[i+1]- bd[i]*a[i])/( s+1.)
            else:
                rd+= bd[i]*a[i]*log( a[i+1]/a[i])         


        m=int(self.Lb1.curselection()[0])
        

        rms=sqrt(ra)
        three_rms=3*rms
    
        print (" ")
        print (" *** Input PSD *** ")
        print (" ")
 
        print (" Acceleration ")
        print ("   Overall = %10.3g GRMS" % rms)
        print ("           = %10.3g 3-sigma" % three_rms)

        grms=rms

        vrms=sqrt(rv)

        if(m==1):
            vrms=(9.81/386.)*vrms

        vthree_rms=3*vrms

        print (" ")
        print (" Velocity ") 

        if(m==0):
            print ("   Overall = %10.3g in/sec rms" % vrms)
            print ("           = %10.3g in/sec 3-sigma" % vthree_rms)
        else:
            print ("   Overall = %10.3g m/sec rms" % vrms)
            print ("           = %10.3g m/sec 3-sigma" % vthree_rms)            


        drms=sqrt(rd)

        if(m==1):
            drms=(9.81/386.)*1000*drms


        dthree_rms=3*drms

        print (" ")
        print (" Displacement ") 
        
        if(m==0):
            print ("   Overall = %10.3g in rms" % drms)
            print ("           = %10.3g in 3-sigma" % dthree_rms)
        else:
            print ("   Overall = %10.3g mm rms" % drms)
            print ("           = %10.3g mm 3-sigma" % dthree_rms)           
        
########
        

        s0='Acceleration'
        s1="%8.3g GRMS" %grms
        self.tree.insert('', 'end', values=(s0,s1))
        
        s0=' '
        s1="%8.3g 3-sigma" %three_rms
        self.tree.insert('', 'end', values=(s0,s1))
     
                
        s0='Velocity'
        if(m==0):
            s1="%8.3g in/sec rms" %vrms
        else:
            s1="%8.3g m/sec rms" %vrms
        self.tree.insert('', 'end', values=(s0,s1))
     
                
        s0=' '
        if(m==0):
            s1="%8.3g in/sec 3-sigma" %vthree_rms
        else:
            s1="%8.3g m/sec 3-sigma" %vthree_rms
        self.tree.insert('', 'end', values=(s0,s1))
 

        s0='Displacement'
        if(m==0):
            s1="%8.3g in rms" %drms
        else:
            s1="%8.3g mm rms" %drms
        self.tree.insert('', 'end', values=(s0,s1))
     
                
        s0=' '
        if(m==0):
            s1="%8.3g in 3-sigma" %dthree_rms
        else:
            s1="%8.3g mm 3-sigma" %dthree_rms
        self.tree.insert('', 'end', values=(s0,s1))
        
        
        self.a=a
        self.b=b
        self.rms=rms
 

        self.plot_psd(self)
        
        
###############################################################################
        
    @classmethod    
    def plot_psd(cls,self):

        print (" ")
        print (" view plot ")

        plt.close(1)        
        plt.figure(1)            
        
        plt.plot(self.a,self.b)
        title_string='Power Spectral Density   '+str("%6.3g" %self.rms)+' GRMS Overall '
        plt.title(title_string)
        plt.ylabel(' Accel (G^2/Hz)')
        plt.xlabel(' Frequency (Hz) ')
        plt.grid(which='both')
        plt.savefig('power_spectral_density')
        plt.xscale('log')
        plt.yscale('log')
        

 
        if not self.fminr.get(): #do something
            f1=min(self.a)         
        else:
            fminp=float(self.fminr.get())
            f1=fminp        

        if not self.fmaxr.get(): #do something
            f2=max(self.a)         
        else:
            fmaxp=float(self.fmaxr.get())
            f2=fmaxp   


        if(abs(f1-10)<0.5 and abs(f2-2000)<4):
            
            ax=plt.gca().xaxis
            ax.set_major_formatter(ScalarFormatter())
            plt.ticklabel_format(style='plain', axis='x', scilimits=(f1,f2))    
              
            extraticks=[10,2000]
            plt.xticks(list(plt.xticks()[0]) + extraticks) 

        
        if(abs(f1-20)<0.5 and abs(f2-2000)<4):
            
            ax=plt.gca().xaxis
            ax.set_major_formatter(ScalarFormatter())
            plt.ticklabel_format(style='plain', axis='x', scilimits=(f1,f2))    
              
            extraticks=[20,2000]
            plt.xticks(list(plt.xticks()[0]) + extraticks)                
        
        
        plt.xlim([f1,f2])        
        
        plt.show()

###############################################################################        
        
###############################################################################
              
def quit(root):
    root.destroy()
                       
###############################################################################