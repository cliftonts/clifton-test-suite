#!/usr/bin/env python
# -*- coding: utf-8 -*-

from subprocess import call 
import pygtk
import os
pygtk.require('2.0')
 
import gtk

inputfile = ""
outputfile = ""
port = ""
test = ""
cts = "False"

class Application():
 
    def __init__(self):
        self.window = gtk.Window()
        self.window.set_title("Clifton Test Suite")
 
        self.create_widgets()
        self.connect_signals()

        self.window.show_all()
        gtk.main()

    #Handles the selection from tester dropdown
    def changed_tester(self, combobox):
        model = combobox.get_model()
        index = combobox.get_active()
        global test
        if index == 1:
           test = "kewtech"
        elif index == 2:
           test = "kewtech"
        elif index == 3:
           test = "primetest"
        elif index == 4:
           test = "primetest"
        return

    #Handles the selection from ports dropdown
    def changed_cb(self, combobox):
        global port
        model = combobox.get_model() #Text of selection
        index = combobox.get_active()#Index number of selection
        port = model[index][0]
        return

    # CTS Tickbox callback
    # The data passed to this method is printed to stdout
    def tickbox(self, widget, data=None):
        global cts
       
        if widget.get_active():
           cts = "True"
        else:
           cts = "False"
  
    def create_widgets(self):
        self.vbox = gtk.VBox(spacing=10)
        #The text window
        self.box2 = gtk.VBox(False, 10)
        self.box2.set_size_request(100,400)
        self.box2.set_border_width(10)
        self.vbox.pack_start(self.box2, True, True, 0)
        self.box2.show()

        sw = gtk.ScrolledWindow()
        sw.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
        textview = gtk.TextView()
        textbuffer = textview.get_buffer()
        sw.add(textview)
        sw.show()
        textview.set_wrap_mode(gtk.WRAP_WORD)
        textview.show()

        self.box2.pack_start(sw)

        textbuffer.set_text('Choose the model of your tester, the input source (on the computer) and where you want to save the output.\nIf the input \'From File\'is selected also choose your input file from your hard disk.\n\nCTS Custom Format\nThis is a custom filter used by Clifton Test Services Ltd in order to speed up data entry on the tester. Descriptive comments are replaced with shortcut codes below:\n\nA - Plug				N - \nB - Socket Change		O - Fuse Cover\nC - Fuse Change		P - \nD - Rewire				Q -\nE - Strain Relief		R - Visual Only\nF - Lead Damage		S - Checked in Situ\nG - Surge Protected	T - Scrapped\nH - Poor/Not Earthed	U - Left in Situ\nI - Low Insulation		V - Management Informed\nJ - Requires RCD		W - Repaired\nK - Faulty Socket		X - Passed\nM - Case Damage		Y - Failed\n						Z - Replaced\n\nFeature requests and bug reports can be emailed to sales@cliftonts.co.uk')

        #Dropdown box - Tester model
        self.tester = gtk.combo_box_new_text()
        self.tester.set_size_request(1,1)
        self.tester.append_text('Select Tester')
        self.tester.append_text('Kewtech KT74')
        self.tester.append_text('Kewtech KT77')
        self.tester.append_text('Seaward Primetest 300')
        self.tester.append_text('Seaward Primetest 350')
        #self.hbox_1.append_text('Peach')
        #self.hbox_1.append_text('Raisin')
        self.tester.connect('changed', self.changed_tester)
        self.tester.set_active(0)

        #Dropdown box - Port
        self.hbox_1 = gtk.combo_box_new_text()
        self.hbox_1.set_size_request(1,1)
        #self.window.add(combobox)
        self.hbox_1.append_text('Select Input')
        self.hbox_1.append_text('/dev/ttyUSB0')
        self.hbox_1.append_text('/dev/rfcomm0')
        self.hbox_1.append_text('File')
        #self.hbox_1.append_text('Grape')
        #self.hbox_1.append_text('Peach')
        #self.hbox_1.append_text('Raisin')
        self.hbox_1.connect('changed', self.changed_cb)
        self.hbox_1.set_active(0)

       #CTS format tickbox
         # Create first button
        button = gtk.CheckButton("CTS Format")

        # When the button is toggled, we call the "callback" method
        # with a pointer to "button" as its argument
        button.connect("toggled", self.tickbox, "CTS Tickbox")


        
        button.show()

        #Add input/output/go buttons
        self.hbox_2 = gtk.HBox(spacing=10)
        self.button_input = gtk.Button("Select Input File")
        self.button_input.set_size_request(1,4)
        self.hbox_2.pack_start(self.button_input)
        self.button_output = gtk.Button("Select Output File")
        self.button_output.set_size_request(1,4)
        self.hbox_2.pack_start(self.button_output)
     
        self.button_go = gtk.Button("GO")
        self.button_go.set_size_request(1,4)
        self.hbox_2.pack_start(self.button_go)

 
        self.vbox.pack_start(self.tester) #Displays port tester
        self.vbox.pack_start(self.hbox_1) #Displays port menu
        self.vbox.pack_start(button, True, True, 2) #Displays CTS Tickbox

        self.vbox.pack_start(self.hbox_2)
 
        self.window.add(self.vbox)
        self.window.set_size_request(600, 600)


    def connect_signals(self):
        self.button_input.connect("clicked", self.callback_input)
        self.button_output.connect("clicked", self.callback_output)
        self.button_go.connect("clicked", self.callback_go)
 
 
    def callback_input(self, widget, callback_data=None):
        #name = self.entry.get_text()
        #print name
        dialog = gtk.FileChooserDialog("Open..",
                               None,
                               gtk.FILE_CHOOSER_ACTION_OPEN,
                               (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL,
                                gtk.STOCK_OPEN, gtk.RESPONSE_OK))
        dialog.set_default_response(gtk.RESPONSE_OK)

        filter = gtk.FileFilter()
        filter.set_name("All files")
        filter.add_pattern("*")
        dialog.add_filter(filter)

        filter = gtk.FileFilter()
        filter.set_name("Images")
        filter.add_mime_type("image/png")
        filter.add_mime_type("image/jpeg")
        filter.add_mime_type("image/gif")
        filter.add_pattern("*.png")
        filter.add_pattern("*.jpg")
        filter.add_pattern("*.gif")
        filter.add_pattern("*.tif")
        filter.add_pattern("*.xpm")
        dialog.add_filter(filter)
        dialog.set_current_folder("~/")

        response = dialog.run()
        if response == gtk.RESPONSE_OK:
            global inputfile
            inputfile = dialog.get_filename()
            #inputfile = inputfile.replace(" ", "\ ")
            #print inputfile
        #elif response == gtk.RESPONSE_CANCEL:
            #print 'Closed, no files selected'
        dialog.destroy()
 
 
    def callback_output(self, widget, callback_data=None):
        #gtk.main_quit()
        dialog = gtk.FileChooserDialog("Save..",
                               None,
                               gtk.FILE_CHOOSER_ACTION_SAVE,
                               (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL,
                                gtk.STOCK_OPEN, gtk.RESPONSE_OK))
        dialog.set_default_response(gtk.RESPONSE_OK)

        filter = gtk.FileFilter()
        filter.set_name("All files")
        filter.add_pattern("*")
        dialog.add_filter(filter)

        filter = gtk.FileFilter()
        filter.set_name("Images")
        filter.add_mime_type("image/png")
        filter.add_mime_type("image/jpeg")
        filter.add_mime_type("image/gif")
        filter.add_pattern("*.png")
        filter.add_pattern("*.jpg")
        filter.add_pattern("*.gif")
        filter.add_pattern("*.tif")
        filter.add_pattern("*.xpm")
        dialog.add_filter(filter)
        dialog.set_current_folder("~/")

        response = dialog.run()
        if response == gtk.RESPONSE_OK:
            global outputfile
            outputfile = dialog.get_filename()
            #outputfile = outputfile.replace(" ", "\ ")
        #elif response == gtk.RESPONSE_CANCEL:
            #print 'Closed, no files selected'
        dialog.destroy() 

    def callback_go(self, widget, callback_data=None):
        global test
        if port == "File" and inputfile == "":
           message = gtk.MessageDialog(type=gtk.MESSAGE_ERROR)
           message.set_markup("Check input file selection and try again.")
           message.run()
        else:
           if outputfile != "" and port != "" and test != "":
              testmode = test
              if cts == "True":
                 testmode = test + "_cts"
              if port == "File":                 
                 cmd = "/opt/cliftontestsuite/"+ testmode + " \"" + inputfile + "\" \"" + outputfile + "\""
              else:
                 cmd = "gksu /opt/cliftontestsuite/"+ testmode + " " + port + " \"" + outputfile + "\""
              #print cmd
              #os.system(cmd)
              call (cmd, shell=True)
           else:
              message = gtk.MessageDialog(type=gtk.MESSAGE_ERROR)
              message.set_markup("Check\nTester Model\nChosen Port\nInput and output file selections\nand try again.")
              message.run()
        

if __name__ == "__main__":
    app = Application()
