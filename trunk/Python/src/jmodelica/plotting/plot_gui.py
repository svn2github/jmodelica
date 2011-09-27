#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2011 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


import matplotlib
matplotlib.interactive(True)
matplotlib.use('WXAgg')

from matplotlib.backends.backend_wxagg import FigureCanvasWxAgg
from matplotlib.figure import Figure

#GUI modules
try:
    import wx
    import wx.lib.agw.customtreectrl as wxCustom
    import wx.lib.agw.aui as aui
except ImportError:
    print "WX-Python not found. The GUI will not work."

#JModelica related imports
try:
    from jmodelica.io import ResultDymolaTextual
except ImportError:
    print "JModelica not found."

#Import general modules
import os as O

ID_GRID    = 15001
ID_LICENSE = 15002
ID_LABELS  = 15003
ID_AXIS    = 15004
ID_MOVE    = 15005
ID_ZOOM    = 15006

class MainGUI(wx.Frame):
    sizeHeightDefault=900
    sizeLengthDefault=675
    sizeHeightMin=100
    sizeLengthMin=130
    sizeTreeMin=200
    sizeTreeDefault=sizeTreeMin+40
    
    def __init__(self, parent, ID):
        
        self.title = "JModelica.org Plot GUI"
        wx.Frame.__init__(self, parent, ID, self.title,
                         wx.DefaultPosition, wx.Size(self.sizeHeightDefault, self.sizeLengthDefault))
                         
        #Handle idle events
        #wx.IdleEvent.SetMode(wx.IDLE_PROCESS_SPECIFIED)
        
        #Variables for the results
        self.ResultFiles = [] #Contains all the result files
        self.PlotVariables = [[]] #Contains all the variables for the different plots
        self.ResultIndex = 0 #Index of the result file
        self.PlotIndex = 0 #Index of the plot variables connected to the different plots
        
        #Settings variables
        self.grid = False
        self.zoom = False
        self.move = True
        
        #Create menus and status bars
        self.CreateStatusBar() #Create a statusbar at the bottom
        self.CreateMenu() #Create the normal menu
        
        #Create the main window
        self.verticalSplitter = wx.SplitterWindow(self, -1, style = wx.CLIP_CHILDREN | wx.SP_LIVE_UPDATE | wx.SP_3D)
        
        #Create the positioners
        self.leftPanel = wx.Panel(self.verticalSplitter)
        self.leftSizer = wx.BoxSizer(wx.VERTICAL)
        self.rightPanel = wx.Panel(self.verticalSplitter)
        self.rightSizer = wx.BoxSizer(wx.VERTICAL)
        
        #Create the panels (Tree and Plot)
        
        if wx.VERSION < (2,8,11,0):
            self.tree = VariableTree(self.leftPanel,style = wx.SUNKEN_BORDER | wxCustom.TR_HAS_BUTTONS | wxCustom.TR_HAS_VARIABLE_ROW_HEIGHT | wxCustom.TR_HIDE_ROOT | wxCustom.TR_ALIGN_WINDOWS)
            self.noteBook = aui.AuiNotebook(self.rightPanel, style= aui.AUI_NB_TOP | aui.AUI_NB_TAB_SPLIT | aui.AUI_NB_TAB_MOVE | aui.AUI_NB_SCROLL_BUTTONS | aui.AUI_NB_CLOSE_ON_ACTIVE_TAB | aui.AUI_NB_DRAW_DND_TAB)
        else:
            self.tree = VariableTree(self.leftPanel,style = wx.SUNKEN_BORDER, agwStyle = wxCustom.TR_HAS_BUTTONS | wxCustom.TR_HAS_VARIABLE_ROW_HEIGHT | wxCustom.TR_HIDE_ROOT | wxCustom.TR_ALIGN_WINDOWS)
            self.noteBook = aui.AuiNotebook(self.rightPanel, agwStyle= aui.AUI_NB_TOP | aui.AUI_NB_TAB_SPLIT | aui.AUI_NB_TAB_MOVE | aui.AUI_NB_SCROLL_BUTTONS | aui.AUI_NB_CLOSE_ON_ACTIVE_TAB | aui.AUI_NB_DRAW_DND_TAB)
        self.plotPanels = [PlotPanel(self.noteBook,self.grid, move=self.move, zoom=self.zoom)]
        self.noteBook.AddPage(self.plotPanels[0],"Plot 1")
        self.filterPanel = FilterPanel(self.leftPanel, self.tree)
        
        
        #Add the panels to the positioners
        self.leftSizer.Add(self.tree,1,wx.EXPAND)
        self.leftSizer.Add(self.filterPanel,0,wx.EXPAND)
        self.rightSizer.Add(self.noteBook,1,wx.EXPAND)
        

        self.verticalSplitter.SplitVertically(self.leftPanel, self.rightPanel,self.sizeTreeDefault)
        #self.verticalSplitter.SetMinimumPaneSize(self.sizeTreeMin)
        self.verticalSplitter.SetMinimumPaneSize(self.filterPanel.GetBestSize()[0])
        
        
        #Position the main windows
        self.leftPanel.SetSizer(self.leftSizer)
        self.rightPanel.SetSizer(self.rightSizer)
        self.mainSizer = wx.BoxSizer() #Create the main positioner
        self.mainSizer.Add(self.verticalSplitter, 1, wx.EXPAND) #Add the vertical splitter
        self.SetSizer(self.mainSizer) #Set the positioner to the main window
        self.SetMinSize((self.sizeHeightMin,self.sizeLengthMin)) #Set minimum sizes
        
        #Bind the exit event from the "cross"
        self.Bind(wx.EVT_CLOSE, self.OnMenuExit)
        #Bind the tree item checked event
        self.tree.Bind(wxCustom.EVT_TREE_ITEM_CHECKED, self.OnTreeItemChecked)
        #Bind the key press event
        self.tree.Bind(wx.EVT_KEY_DOWN, self.OnKeyPress)
        #Bind the closing of a tab
        self.Bind(aui.EVT_AUINOTEBOOK_PAGE_CLOSE, self.OnCloseTab, self.noteBook)
        #Bind the changing of a tab
        self.Bind(aui.EVT_AUINOTEBOOK_PAGE_CHANGING, self.OnTabChanging, self.noteBook)
        #Bind the changed of a tab
        self.Bind(aui.EVT_AUINOTEBOOK_PAGE_CHANGED, self.OnTabChanged, self.noteBook)

        self.Centre(True) #Position the GUI in the centre of the screen
        self.Show(True) #Show the Plot GUI
        
    def CreateMenu(self):
        #Creating the menu
        filemenu = wx.Menu()
        helpmenu = wx.Menu()
        editmenu = wx.Menu()
        viewmenu = wx.Menu()
        menuBar  = wx.MenuBar()
        
        #Create the menu options
        # Main
        self.menuOpen  = filemenu.Append(wx.ID_OPEN, "&Open\tCtrl+O","Open a result.")
        self.menuSaveFig = filemenu.Append(wx.ID_SAVE, "&Save\tCtrl+S", "Save the current figure.")
        filemenu.AppendSeparator() #Append a seperator between Open and Exit
        self.menuExit  = filemenu.Append(wx.ID_EXIT,"E&xit\tCtrl+X"," Terminate the program.")
        
        # Edit
        self.editAdd  = editmenu.Append(wx.ID_ADD,"A&dd Plot","Add a plot window.")
        self.editLabels = editmenu.Append(ID_LABELS, "Labels", "Edit the labels of the current plot.")
        self.editAxis = editmenu.Append(ID_AXIS,"Axis", "Edit the axis of the current plot.")
        
        # View
        self.viewGrid  = viewmenu.Append(ID_GRID,"&Grid","Show/Hide Grid.",kind=wx.ITEM_CHECK)
        viewmenu.AppendSeparator() #Append a seperator
        self.viewMove = viewmenu.Append(ID_MOVE,"Move","Use the mouse to move the plot.",kind=wx.ITEM_RADIO)
        self.viewZoom = viewmenu.Append(ID_ZOOM,"Zoom","Use the mouse for zooming.",kind=wx.ITEM_RADIO)
        
        # Help
        self.helpLicense = helpmenu.Append(ID_LICENSE, "License","Show the license.")
        self.helpAbout = helpmenu.Append(wx.ID_ABOUT, "&About"," Information about this program.")
  
        #Setting up the menu
        menuBar.Append(filemenu,"&File") #Adding the "filemenu" to the MenuBar
        menuBar.Append(editmenu,"&Edit") #Adding the "editmenu" to the MenuBar
        menuBar.Append(viewmenu,"&View") #Adding the "viewmenu" to the MenuBar
        menuBar.Append(helpmenu,"&Help") #Adding the "helpmenu" to the MenuBar
        
        #Binding the events
        self.Bind(wx.EVT_MENU, self.OnMenuOpen,    self.menuOpen)
        self.Bind(wx.EVT_MENU, self.OnMenuSaveFig, self.menuSaveFig)
        self.Bind(wx.EVT_MENU, self.OnMenuExit,    self.menuExit)
        self.Bind(wx.EVT_MENU, self.OnMenuAdd,     self.editAdd)
        self.Bind(wx.EVT_MENU, self.OnMenuLabels,  self.editLabels)
        self.Bind(wx.EVT_MENU, self.OnMenuAxis,    self.editAxis)
        self.Bind(wx.EVT_MENU, self.OnMenuGrid,    self.viewGrid)
        self.Bind(wx.EVT_MENU, self.OnMenuMove,    self.viewMove)
        self.Bind(wx.EVT_MENU, self.OnMenuZoom,    self.viewZoom)
        self.Bind(wx.EVT_MENU, self.OnMenuLicense, self.helpLicense)
        self.Bind(wx.EVT_MENU, self.OnMenuAbout,   self.helpAbout)
                
        self.SetMenuBar(menuBar)  # Adding the MenuBar to the Frame content.
        
        #Set keyboard shortcuts       
        hotKeysTable = wx.AcceleratorTable([(wx.ACCEL_CTRL, ord("O"), self.menuOpen.GetId()),
                                            (wx.ACCEL_CTRL, ord("S"), self.menuSaveFig.GetId()),
                                            (wx.ACCEL_CTRL, ord("X"), self.menuExit.GetId())])
        self.SetAcceleratorTable(hotKeysTable)
    
    def OnMenuMove(self, event):
        self.move = True
        self.zoom = False
        
        for i in range(self.noteBook.GetPageCount()):
            self.noteBook.GetPage(i).UpdateSettings(move = self.move,
                                                    zoom = self.zoom)
        
    def OnMenuZoom(self, event):
        self.move = False
        self.zoom = True
        
        for i in range(self.noteBook.GetPageCount()):
            self.noteBook.GetPage(i).UpdateSettings(move = self.move,
                                                    zoom = self.zoom)
    
    def OnMenuExit(self, event):
        self.Destroy() #Close the GUI
    
    def OnMenuAbout(self, event):
        dlg = wx.MessageDialog(self, 'JModelica.org Plot GUI.\n', 'About',
                                        wx.OK | wx.ICON_INFORMATION)
        dlg.ShowModal()
        dlg.Destroy()
        
    def OnMenuOpen(self, event):
        #Open the file window
        dlg = wx.FileDialog(self, "Open result file(s)",wildcard="Text files (.txt)|*.txt| All files (*.*)|*.*",
                            style=wx.FD_MULTIPLE)
        
        #If OK load the results
        if dlg.ShowModal() == wx.ID_OK:
            for n in dlg.GetFilenames():
                self.SetStatusText("Loading "+n+"...") #Change the statusbar
                
                self.ResultFiles.append((n,ResultDymolaTextual(O.path.join(dlg.GetDirectory(),n))))
                self.tree.AddTreeNode(self.ResultFiles[-1][1], self.ResultFiles[-1][0], 
                                            self.filterPanel.checkBoxTimeVarying.GetValue(),
                                            self.filterPanel.checkBoxParametersConstants.GetValue())
                
                self.ResultIndex += 1 #Increment the index
                
                self.SetStatusText("") #Change the statusbar
        
        dlg.Destroy() #Destroy the popup window
    
    def OnMenuSaveFig(self, event):
        #Open the file window
        dlg = wx.FileDialog(self, "Choose a filename to save to",wildcard="Portable Network Graphics (*.png)|*.png|" \
                                                                          "Encapsulated Postscript (*.eps)|*.eps|" \
                                                                          "Enhanced Metafile (*.emf)|*.emf|" \
                                                                          "Portable Document Format (*.pdf)|*.pdf|" \
                                                                          "Postscript (*.ps)|*.ps|" \
                                                                          "Raw RGBA bitmap (*.raw *.rgba)|*.raw;*.rgba|" \
                                                                          "Scalable Vector Graphics (*.svg *.svgz)|*.svg;*.svgz",
                            style=wx.FD_SAVE | wx.FD_OVERWRITE_PROMPT)
        
        #If OK save the figure
        if dlg.ShowModal() == wx.ID_OK:
            self.SetStatusText("Saving figure...") #Change the statusbar

            IDPlot = self.noteBook.GetSelection()
            self.noteBook.GetPage(IDPlot).Save(dlg.GetPath())
            
            self.SetStatusText("") #Change the statusbar
        
        dlg.Destroy() #Destroy the popup window
        
    
    def OnMenuAdd(self, event):
        #Add a new list for the plot variables connect to the plot
        self.PlotVariables.append([])
        self.PlotIndex += 1
        
        #Add a new plot panel to the notebook
        self.plotPanels.append(PlotPanel(self.noteBook,self.grid,move=self.move, zoom=self.zoom))
        self.noteBook.AddPage(self.plotPanels[-1],"Plot "+str(self.PlotIndex+1))
        
        #Enable labels and axis options
        self.editLabels.Enable(True)
        self.editAxis.Enable(True)
        
    def OnMenuLabels(self, event):
        IDPlot = self.noteBook.GetSelection()
        plotWindow = self.noteBook.GetPage(IDPlot)
        
        #Create the labels dialog
        dlg = DialogLabels(self,plotWindow)
        
        #Open the dialog and update options if OK
        if dlg.ShowModal() == wx.ID_OK:
            
            title,xlabel,ylabel = dlg.GetLabelInfo()
            
            plotWindow.UpdateSettings(title=title,xlabel=xlabel,ylabel=ylabel)
            plotWindow.DrawSettings()
        
        #Destroy the dialog
        dlg.Destroy()
        
    def OnMenuAxis(self, event):
        IDPlot = self.noteBook.GetSelection()
        plotWindow = self.noteBook.GetPage(IDPlot)
        
        #Create the axis dialog
        dlg = DialogAxis(self,self.noteBook.GetPage(IDPlot))
        
        #Open the dialog and update options if OK
        if dlg.ShowModal() == wx.ID_OK:
            
            xmax,xmin,ymax,ymin = dlg.GetAxisValues()
            
            try:
                xmax=float(xmax)
            except ValueError:
                xmax=None
            try:
                xmin=float(xmin)
            except ValueError:
                xmin=None
            try:
                ymax=float(ymax)
            except ValueError:
                ymax=None
            try:
                ymin=float(ymin)
            except ValueError:
                ymin=None
            
            plotWindow.UpdateSettings(axes=[xmin,xmax,ymin,ymax])#(xmax=xmax,xmin=xmin,ymax=ymax,ymin=ymin)
            plotWindow.DrawSettings()
        
        #Destroy the dialog
        dlg.Destroy()
        
    def OnMenuGrid(self, event):
        self.grid = not self.grid
        
        for i in range(self.noteBook.GetPageCount()):
            self.noteBook.GetPage(i).UpdateSettings(grid = self.grid)
            self.noteBook.GetPage(i).DrawSettings()
        
    def OnTreeItemChecked(self, event):
        self.SetStatusText("Drawing figure...")
        
        item = event.GetItem()
        
        ID = self.tree.FindIndexParent(item)
        IDPlot = self.noteBook.GetSelection()

        #Store plot variables or "unstore" in the self.PlotVariables
        
        if self.tree.IsItemChecked(item): #Draw

            data = self.tree.GetPyData(item)
            self.PlotVariables[IDPlot].append([ID,data["traj"],item,data["name"]])
            
        else: #Undraw
            for i,var in enumerate(self.PlotVariables[IDPlot]):
                if var[2]==item:
                    self.PlotVariables[IDPlot].pop(i)
            
        self.noteBook.GetPage(IDPlot).Draw(self.PlotVariables[IDPlot])

        self.SetStatusText("")
        
    def OnKeyPress(self, event):
        keycode = event.GetKeyCode() #Get the key pressed
        
        #If the key is Delete
        if keycode == wx.WXK_DELETE:
            self.SetStatusText("Deleting Result...")

            ID = self.tree.FindIndexParent(self.tree.GetSelection())
            IDPlot = self.noteBook.GetSelection()

            if ID >= 0: #If id is less then 0, no item is selected
                
                self.ResultFiles.pop(ID) #Delete the result object from the list
                self.tree.DeleteParent(self.tree.GetSelection())
                
                #Delete the results connected to the ResultFile
                for i in range(len(self.PlotVariables)):
                    j = 0
                    while j < len(self.PlotVariables[i]):
                        if self.PlotVariables[i][j][0] == ID:
                            self.PlotVariables[i].pop(j)
                        else:
                            j = j+1

                        if j==len(self.PlotVariables[i]):
                            break
                #Redraw
                for i in range(self.noteBook.GetPageCount()):
                    self.noteBook.GetPage(i).Draw(self.PlotVariables[i])

            self.SetStatusText("")
    
    def OnCloseTab(self, event):
        self.OnTabChanging(event)
        self.PlotVariables.pop(event.GetSelection()) #Delete the plot
        self.plotPanels.pop(event.GetSelection()) #MAYBE!
                            #variables associated with the current plot
        
        #Disable changing of labels and axis if there is no Plot
        if self.noteBook.GetPageCount() == 1:
            self.editLabels.Enable(False)
            self.editAxis.Enable(False)
                            
    def OnTabChanging(self, event):
        IDPlot = self.noteBook.GetSelection()
        
        #Uncheck the items related to the previous plot
        if IDPlot != -1:
            for i,var in enumerate(self.PlotVariables[IDPlot]):
                self.tree.CheckItem2(var[2],checked=False,torefresh=True)
    
    def OnTabChanged(self,event):
        IDPlot = self.noteBook.GetSelection()
        
        #Check the items related to the previous plot
        if IDPlot != -1:
            for i,var in enumerate(self.PlotVariables[IDPlot]):
                self.tree.CheckItem2(var[2],checked=True,torefresh=True)

    def OnMenuLicense(self, event):
        
        desc = "Copyright (C) 2011 Modelon AB\n\n"\
"This program is free software: you can redistribute it and/or modify "\
"it under the terms of the GNU General Public License as published by "\
"the Free Software Foundation, version 3 of the License.\n\n"\
"This program is distributed in the hope that it will be useful, "\
"but WITHOUT ANY WARRANTY; without even the implied warranty of "\
"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the "\
"GNU General Public License for more details.\n\n"\
"You should have received a copy of the GNU General Public License "\
"along with this program.  If not, see <http://www.gnu.org/licenses/>. "
        
        dlg = wx.MessageDialog(self, desc, 'License', wx.OK | wx.ICON_INFORMATION)
        dlg.ShowModal()
        dlg.Destroy()

        
class VariableTree(wxCustom.CustomTreeCtrl):
    def __init__(self, *args, **kwargs):
        super(VariableTree, self).__init__(*args, **kwargs)
        
        #Add the root item
        self.root = self.AddRoot("Result(s)")
        #Root have children
        self.SetItemHasChildren(self.root)
        
    def AddTreeNode(self, resultObject, name,timeVarying=None,parametersConstants=None):
        child = self.AppendItem(self.root, name)
        self.SetItemHasChildren(child,True)
        
        rec = {"root":child}

        for item in resultObject.name:
            spl = item.split(".")
            
            #Python object for storing data related to the variable
            data={}
            data["timevarying"] = resultObject.is_variable(item)
            data["traj"] = resultObject.get_variable_data(item)
            data["name"] = item

            if len(spl)==1:
                #if data["timevarying"]:
                self.AppendItem(child, item,ct_type=1, data=data)
                #else:
                #    self.AppendItem(child, item,ct_type=1, wnd=wx.TextCtrl(self, -1, str(data["traj"].x[0]),style = wx.TE_RIGHT | wx.TE_READONLY,size =(60,-1)), data=data) 
            else:
                for i in range(len(spl)-1):
                    
                    #Handle variables of type der(---.---.x)
                    if spl[0].startswith("der(") and spl[-1].endswith(")"):
                        spl[0]=spl[0][4:]
                        spl[-1] = "der("+spl[-1]
                    
                    #See if the sub directory already been added, else add
                    try:
                        rec["".join(spl[:i+1])]
                    except KeyError:
                        if i==0:
                            rec["".join(spl[:i+1])] = self.AppendItem(child, spl[i])
                        else:
                            rec["".join(spl[:i+1])] = self.AppendItem(rec["".join(spl[:i])], spl[i])
                        self.SetItemHasChildren(rec["".join(spl[:i+1])],True)
                else:
                    #if data["timevarying"]:
                    self.AppendItem(rec["".join(spl[:-1])], spl[-1], ct_type=1, data=data)
                    #else:
                    #    self.AppendItem(rec["".join(spl[:-1])], spl[-1], ct_type=1, wnd=wx.TextCtrl(self, -1, str(data["traj"].x[0]),style = wx.TE_RIGHT | wx.TE_READONLY,size =(60,-1)), data=data)
                        
        self.SortChildren(child)
        
        #Hide nodes if options are choosen
        self.HideNodes(timeVarying,parametersConstants)
    
    def FindLoneChildDown(self, child):
        """
        Search for the youngest child down the tree from "child".
        
        Parameters::
        
            child - The item from where the search should start.
            
        Returns::
        
            child - The youngest child from the starting point.
        """
        while True:
            nextItem,cookie = self.GetNextChild(child,0)
            if nextItem != None:
                child = nextItem
            else:
                break
        return child
    
    def FindFirstSiblingUp(self,child,itemParent):
        """
        Search for the first sibling of "child" going up in tree.
        """
        while child != itemParent:
            nextItem = self.GetNextSibling(child)
            
            if nextItem != None:
                return nextItem

            child = self.GetItemParent(child)
        return child
    
    def HideNodes(self, hideTimeVarying=None, hideParametersConstants=None):
        """
        Hide nodes depending on the input.
        
        Parameters::
        
            hideTimeVarying - Hides or Shows the time varying variables.
            
            hideParametersConstants - Hides or Show the parameters.
        """
        
        itemParent = self.GetRootItem()
        child,cookie = self.GetFirstChild(itemParent)
        
        while child != itemParent and child !=None:
            #Find the first youngest child
            child = self.FindLoneChildDown(child)
            
            #Enable or disable depending on input to method
            if hideTimeVarying != None and self.GetPyData(child)["timevarying"]:
                self.EnableItem(child,hideTimeVarying)
            if hideParametersConstants != None and not self.GetPyData(child)["timevarying"]:
                self.EnableItem(child,hideParametersConstants)
            
            #Find the first sibling up
            child = self.FindFirstSiblingUp(child, itemParent)
    
    def DeleteParent(self, item):
        """
        Delete the oldest parent of item, except root.
        """
        
        if item == self.GetRootItem():
            return False
        
        parentItem = self.GetItemParent(item)
        
        while parentItem != self.GetRootItem():
            item = parentItem
            parentItem = self.GetItemParent(item)

        self.Delete(item) #Delete the parent from the Tree
        
    def FindIndexParent(self, item):
        """
        Find the index of the oldest parent of item from one level down
        from root.
        """

        if item == self.GetRootItem():
            return -1
        
        parentItem = item
        item = self.GetItemParent(parentItem)
        
        while item != self.GetRootItem():
            parentItem = item
            item = self.GetItemParent(parentItem)
        
        root = self.GetRootItem()
        sibling,cookie = self.GetFirstChild(root)
        
        index = 0
        while parentItem != sibling:
            sibling = self.GetNextSibling(sibling)
            index += 1
            
        return index
        
        
class DialogLabels(wx.Dialog):
    def __init__(self, parent, plotPage):
        wx.Dialog.__init__(self, parent, -1, "Labels",size=(190,200))
        
        
        settings = plotPage.GetSettings()
        
        mainSizer = wx.BoxSizer(wx.VERTICAL)
        flexGrid = wx.FlexGridSizer(3, 2, 10, 10)
        
        plotTitleStatic = wx.StaticText(self, -1, "Title :")
        plotXLabelStatic = wx.StaticText(self, -1, "X-Label :")
        plotYLabelStatic = wx.StaticText(self, -1, "Y-Label :")
        
        self.plotTitle = wx.TextCtrl(self, -1, settings["Title"], style = wx.TE_LEFT , size =(100,-1))
        self.plotXLabel = wx.TextCtrl(self, -1, settings["XLabel"], style = wx.TE_LEFT , size =(100,-1))
        self.plotYLabel = wx.TextCtrl(self, -1, settings["YLabel"], style = wx.TE_LEFT , size =(100,-1))
        
        #Add the checkboxes to the flexgrid
        flexGrid.Add(plotTitleStatic)
        flexGrid.Add(self.plotTitle)
        flexGrid.Add(plotXLabelStatic)
        flexGrid.Add(self.plotXLabel)
        flexGrid.Add(plotYLabelStatic)
        flexGrid.Add(self.plotYLabel)
        
        
        flexGrid.AddGrowableCol(1, 1)
        
        #Create OK and Cancel buttons
        buttonSizer =  self.CreateButtonSizer(wx.CANCEL|wx.OK)
        
        #Add information to the sizers
        mainSizer.Add(flexGrid,0,wx.ALL|wx.EXPAND,10)
        mainSizer.Add(buttonSizer,1,wx.ALL|wx.EXPAND,10)
        
        #Set the main sizer to the panel
        self.SetSizer(mainSizer)
        
    def GetLabelInfo(self):
        """
        Return the label values.
        
        Returns::
        
            title, xlabel, ylabel
        """
        
        title = self.plotTitle.GetValue()
        xlabel = self.plotXLabel.GetValue()
        ylabel = self.plotYLabel.GetValue()
        
        return title, xlabel, ylabel
        
class DialogAxis(wx.Dialog):
    def __init__(self, parent, plotPage):
        wx.Dialog.__init__(self, parent, -1, "Axis",size=(190,200))
        
        settings = plotPage.GetSettings()
        
        plotXAxisStatic = wx.StaticText(self, -1, "X-Axis :")
        plotYAxisStatic = wx.StaticText(self, -1, "Y-Axis :")
        
        plotMaxStatic = wx.StaticText(self, -1, "Max", style=wx.ALIGN_CENTER,size =(50,-1))
        plotMinStatic = wx.StaticText(self, -1, "Min", style=wx.ALIGN_CENTER,size =(50,-1))
        plotNoneStatic = wx.StaticText(self, -1, "")
        
        self.plotYAxisMin = wx.TextCtrl(self, -1, "" if settings["YAxisMin"]==None else str(settings["YAxisMin"]), style = wx.TE_RIGHT , size =(50,-1))
        self.plotYAxisMax = wx.TextCtrl(self, -1, "" if settings["YAxisMax"]==None else str(settings["YAxisMax"]), style = wx.TE_RIGHT , size =(50,-1))
        self.plotXAxisMin = wx.TextCtrl(self, -1, "" if settings["XAxisMin"]==None else str(settings["XAxisMin"]), style = wx.TE_RIGHT , size =(50,-1))
        self.plotXAxisMax = wx.TextCtrl(self, -1, "" if settings["XAxisMax"]==None else str(settings["XAxisMax"]), style = wx.TE_RIGHT , size =(50,-1))
        
        
        mainSizer = wx.BoxSizer(wx.VERTICAL)
        flexGrid = wx.FlexGridSizer(3, 3, 10, 10)
        
        #Add the checkboxes to the flexgrid
        flexGrid.Add(plotNoneStatic)
        flexGrid.Add(plotMinStatic)
        flexGrid.Add(plotMaxStatic)
        flexGrid.Add(plotYAxisStatic)
        flexGrid.Add(self.plotYAxisMin)
        flexGrid.Add(self.plotYAxisMax)
        flexGrid.Add(plotXAxisStatic)
        flexGrid.Add(self.plotXAxisMin)
        flexGrid.Add(self.plotXAxisMax)
        
        flexGrid.AddGrowableCol(2, 1)
        
        #Create OK and Cancel buttons
        buttonSizer =  self.CreateButtonSizer(wx.CANCEL|wx.OK)
        
        #Add information to the sizers
        mainSizer.Add(flexGrid,0,wx.ALL|wx.EXPAND,10)
        mainSizer.Add(buttonSizer,1,wx.ALL|wx.EXPAND,10)
        
        #Set the main sizer to the panel
        self.SetSizer(mainSizer)
        
    def GetAxisValues(self):
        """
        Return the axis values.
        
        Returns::
        
            xmax, xmin, ymax, ymin
        """
        
        xmax = self.plotXAxisMax.GetValue()
        xmin = self.plotXAxisMin.GetValue()
        ymax = self.plotYAxisMax.GetValue()
        ymin = self.plotYAxisMin.GetValue()
        
        return xmax,xmin,ymax,ymin

class FilterPanel(wx.Panel):
    def __init__(self, parent,tree, **kwargs):
        wx.Panel.__init__( self, parent, **kwargs )
        
        #Store the parent
        self.parent = parent
        self.tree = tree
        
        mainSizer = wx.BoxSizer(wx.VERTICAL)
        
        topBox = wx.StaticBox(self, label = "Filter")
        topSizer = wx.StaticBoxSizer(topBox, wx.VERTICAL)
        
        
        flexGrid = wx.FlexGridSizer(2, 1, 10, 10)
        
        #Create the checkboxes
        self.checkBoxParametersConstants = wx.CheckBox(self, -1, " Parameters / Constants")#, size=(140, -1))
        self.checkBoxTimeVarying = wx.CheckBox(self, -1, " Time-Varying", size=(140, -1))
        
        #Check the checkboxes
        self.checkBoxParametersConstants.SetValue(True)
        self.checkBoxTimeVarying.SetValue(True)
        
        #Add the checkboxes to the flexgrid
        flexGrid.Add(self.checkBoxParametersConstants)
        flexGrid.Add(self.checkBoxTimeVarying)

        flexGrid.AddGrowableCol(0)
        
        #Add information to the sizers
        topSizer.Add(flexGrid,1,wx.ALL|wx.EXPAND,10)
        mainSizer.Add(topSizer,0,wx.EXPAND|wx.ALL,10)
        
        #Set the main sizer to the panel
        self.SetSizer(mainSizer)
        
        #Bind events
        self.Bind(wx.EVT_CHECKBOX, self.OnParametersConstants, self.checkBoxParametersConstants)
        self.Bind(wx.EVT_CHECKBOX, self.OnTimeVarying, self.checkBoxTimeVarying)
        
    def OnParametersConstants(self, event):
        self.tree.HideNodes(hideParametersConstants=self.checkBoxParametersConstants.GetValue())
        
    def OnTimeVarying(self, event):
        self.tree.HideNodes(hideTimeVarying=self.checkBoxTimeVarying.GetValue())

class PlotPanel(wx.Panel):
    def __init__(self, parent, grid=False,move=True,zoom=False, **kwargs):
        wx.Panel.__init__( self, parent, **kwargs )

        #Initialize matplotlib
        self.figure = Figure(facecolor = 'white')
        self.canvas = FigureCanvasWxAgg(self, -1, self.figure)
        self.subplot = self.figure.add_subplot( 111 )

        self.parent = parent
        
        self.settings = {}
        self.settings["Grid"] = grid
        self.settings["Zoom"] = zoom
        self.settings["Move"] = move
        self.settings["Title"] = ""
        self.settings["XLabel"] = "Time [s]"
        self.settings["YLabel"] = ""
        self.settings["XAxisMax"] = None
        self.settings["XAxisMin"] = None
        self.settings["YAxisMax"] = None
        self.settings["YAxisMin"] = None

        self._resizeflag = False

        self._SetSize()
        self.DrawSettings()
        
        #Bind events
        self.Bind(wx.EVT_IDLE, self.OnIdle)
        self.Bind(wx.EVT_SIZE, self.OnSize)
        
        #Bind event for resizing (must bind to canvas)
        self.canvas.Bind(wx.EVT_RIGHT_DOWN, self.OnRightDown)
        
        self.canvas.Bind(wx.EVT_LEFT_DOWN, self.OnLeftDown)
        self.canvas.Bind(wx.EVT_LEFT_UP, self.OnLeftUp)
        self.canvas.Bind(wx.EVT_LEAVE_WINDOW, self.OnLeaveWindow)
        self.canvas.Bind(wx.EVT_ENTER_WINDOW, self.OnEnterWindow)
        self.canvas.Bind(wx.EVT_MOTION, self.OnMotion)
        self.canvas.Bind(wx.EVT_LEFT_DCLICK, self.OnPass)
        
        self._mouseLeftPressed = False
        self._mouseMoved = False
    
    def OnPass(self, event):
        pass
    
    def OnMotion(self, event):
        
        if self._mouseLeftPressed: #Is the mouse pressed?
            self._mouseMoved = True
            self._newPos = event.GetPosition()
            
            if self.settings["Move"]:
                self.DrawMove()
            if self.settings["Zoom"]:
                self.DrawRectZoom()
    
    def DrawZoom(self):
        try:
            y0 = self._figureMin[1][1]-self._lastZoomRect[1]
            x0 = self._lastZoomRect[0]-self._figureMin[0][0]
            w = self._lastZoomRect[2]
            h = self._lastZoomRect[3]
            fullW = self._figureMin[1][0]-self._figureMin[0][0]
            fullH = self._figureMin[1][1]-self._figureMin[0][1]
            
            if w < 0:
                x0 = x0 + w
            x0 = max(x0, 0.0)
            y0 = max(y0, 0.0)
            
            plotX0 = self.subplot.get_xlim()[0]
            plotY0 = self.subplot.get_ylim()[0]
            plotW = self.subplot.get_xlim()[1]-self.subplot.get_xlim()[0]
            plotH = self.subplot.get_ylim()[1]-self.subplot.get_ylim()[0]
            
            self.settings["XAxisMin"] = plotX0+abs(x0/fullW*plotW)
            self.settings["XAxisMax"] = plotX0+abs(x0/fullW*plotW)+abs(w/fullW*plotW)
            self.settings["YAxisMin"] = plotY0+abs(y0/fullH*plotH)
            self.settings["YAxisMax"] = plotY0+abs(y0/fullH*plotH)+abs(h/fullH*plotH)
            
            self.DrawRectZoom(drawNew=False) #Delete the last zoom rectangle
            self.DrawSettings()
        except AttributeError:
            self.DrawRectZoom(drawNew=False) #Delete the last zoom rectangle
    
    def DrawMove(self):
        
        x0,y0 = self._originalPos
        x1,y1 = self._newPos
        
        fullW = self._figureMin[1][0]-self._figureMin[0][0]
        fullH = self._figureMin[1][1]-self._figureMin[0][1]
        
        plotX0,plotY0,plotW,plotH = self._plotInfo

        self.settings["XAxisMin"] = plotX0+(x0-x1)/fullW*plotW
        self.settings["XAxisMax"] = plotX0+plotW+(x0-x1)/fullW*plotW
        self.settings["YAxisMin"] = plotY0+(y1-y0)/fullH*plotH
        self.settings["YAxisMax"] = plotY0+plotH+(y1-y0)/fullH*plotH
        
        self.DrawSettings()    
    
    def DrawRectZoom(self, drawNew=True):
        dc = wx.ClientDC(self.canvas)
        dc.SetLogicalFunction(wx.XOR)

        wbrush =wx.Brush(wx.Colour(255,255,255), wx.TRANSPARENT)
        wpen =wx.Pen(wx.Colour(200, 200, 200), 1, wx.SOLID)
        dc.SetBrush(wbrush)
        dc.SetPen(wpen)


        dc.ResetBoundingBox()
        dc.BeginDrawing()
            
        y1 = min(max(self._newPos[1],self._figureMin[0][1]),self._figureMin[1][1])
        y0 = min(max(self._originalPos[1],self._figureMin[0][1]),self._figureMin[1][1])
        x1 = min(max(self._newPos[0],self._figureMin[0][0]),self._figureMin[1][0])
        x0 = min(max(self._originalPos[0],self._figureMin[0][0]),self._figureMin[1][0])

        if y1 > y0: 
            y0, y1 = y1, y0
        if x1 < y0: 
            x0, x1 = x1, x0

        w = x1 - x0
        h = y1 - y0

        rectZoom = int(x0), int(y0), int(w), int(h)

        try: 
            self._lastZoomRect
        except AttributeError: 
            pass
        else: 
            dc.DrawRectangle(*self._lastZoomRect)  #erase last
        
        if drawNew:
            self._lastZoomRect = rectZoom
            dc.DrawRectangle(*rectZoom)
        else:
            try:
                del self._lastZoomRect
            except AttributeError:
                pass
        dc.EndDrawing()
        #dc.Destroy()
        
    def OnLeftDown(self, event):
        self._mouseLeftPressed = True #Mouse is pressed
        
        #Capture mouse position
        self._originalPos = event.GetPosition()
        #Capture figure size
        self._figureRatio = self.subplot.get_position().get_points()
        self._figureSize = (self.canvas.figure.bbox.width,self.canvas.figure.bbox.height)
        self._figureMin = [(round(self._figureSize[0]*self._figureRatio[0][0]),round(self._figureSize[1]*self._figureRatio[0][1])),
                           (round(self._figureSize[0]*self._figureRatio[1][0]),round(self._figureSize[1]*self._figureRatio[1][1]))]
        #Capture current plot
        plotX0 = self.subplot.get_xlim()[0]
        plotY0 = self.subplot.get_ylim()[0]
        plotW = self.subplot.get_xlim()[1]-self.subplot.get_xlim()[0]
        plotH = self.subplot.get_ylim()[1]-self.subplot.get_ylim()[0]
        self._plotInfo = (plotX0, plotY0, plotW, plotH)
        
        
    def OnLeftUp(self, event):
        self._mouseLeftPressed = False #Mouse is not pressed
        if self._mouseMoved:
            self._mouseMoved = False
            
            if self.settings["Zoom"]:
                self.DrawZoom()
            if self.settings["Move"]:
                self.DrawMove()

    def OnLeaveWindow(self, event): #Change cursor
        if self._mouseLeftPressed:
            self._mouseLeftPressed = False #Mouse not pressed anymore
            self._mouseMoved = False
            
            if self.settings["Zoom"]:
                self.DrawZoom()
            if self.settings["Move"]:
                self.DrawMove()
        
    def OnEnterWindow(self, event): #Change cursor
        self.UpdateCursor()
    
    def OnRightDown(self, event):
        """
        On right click, resize the plot.
        """
        self.UpdateSettings(axes=[None,None,None,None])
        self.DrawSettings()

    def OnSize(self, event):
        self._resizeflag = True

    def OnIdle(self, event):
        if self._resizeflag:
            self._resizeflag = False
            self._SetSize()

    def _SetSize(self):
        pixels = tuple(self.GetClientSize())
        #self.SetSize(pixels) #GENERATES INFINITELY EVENTS ON UBUNTU
        self.canvas.SetSize(pixels)
        self.figure.set_size_inches(float(pixels[0])/self.figure.get_dpi(),
                                    float(pixels[1])/self.figure.get_dpi())
                                     
    def Draw(self, variables=[]):
        self.subplot.clear()
        self.subplot.hold(True)

        for i in variables:
            self.subplot.plot(i[1].t, i[1].x,label=i[3])
        
        if len(variables) != 0:
            self.subplot.legend()
        
        self.DrawSettings()

    def Save(self, filename):
        """
        Saves the current figure.
        
        Parameters::
        
            filename - The name of the to be saved plot.
        """
        self.figure.savefig(filename)
        
    def DrawSettings(self):
        """
        Draws the current settings onto the Plot.
        """
        
        self.subplot.grid(self.settings["Grid"])

        #Draw label settings
        self.subplot.set_title(self.settings["Title"])
        self.subplot.set_xlabel(self.settings["XLabel"])
        self.subplot.set_ylabel(self.settings["YLabel"])

        #Draw axis settings
        if self.settings["XAxisMin"] != None:
            #self.subplot.set_xlim(left=self.settings["XAxisMin"])
            self.subplot.set_xlim(xmin=self.settings["XAxisMin"])
        if self.settings["XAxisMax"] != None:
            #self.subplot.set_xlim(right=self.settings["XAxisMax"])
            self.subplot.set_xlim(xmax=self.settings["XAxisMax"])
        if self.settings["XAxisMax"] == None and self.settings["XAxisMin"] == None:
            self.subplot.set_xlim(None,None)
            self.subplot.set_autoscalex_on(True)
            #self.subplot.autoscale(axis="x")
            self.subplot.autoscale_view(scalex=True)
        
        if self.settings["YAxisMin"] != None:
            #self.subplot.set_ylim(bottom=self.settings["YAxisMin"])
            self.subplot.set_ylim(ymin=self.settings["YAxisMin"])
        if self.settings["YAxisMax"] != None:
            #self.subplot.set_ylim(top=self.settings["YAxisMax"])
            self.subplot.set_ylim(ymax=self.settings["YAxisMax"])
        if self.settings["YAxisMax"] == None and self.settings["YAxisMin"] == None:
            self.subplot.set_ylim(None,None)
            self.subplot.set_autoscaley_on(True)
            #self.subplot.autoscale(axis="y") #METHOD DOES NOT EXIST ON VERSION LESS THAN 1.0
            self.subplot.autoscale_view(scaley=True)

        #Draw
        self.canvas.draw()
        
    def UpdateSettings(self, grid=None, title=None, xlabel=None,
                        ylabel=None, axes=None, move=None, zoom=None):
        """
        Updates the settings dict.
        """
        if grid !=None:
            self.settings["Grid"] = grid
        if title !=None:
            self.settings["Title"] = title
        if xlabel !=None:
            self.settings["XLabel"] = xlabel
        if ylabel !=None:
            self.settings["YLabel"] = ylabel
        if axes != None:
            self.settings["XAxisMin"]=axes[0]
            self.settings["XAxisMax"]=axes[1]
            self.settings["YAxisMin"]=axes[2]
            self.settings["YAxisMax"]=axes[3]
        if move != None:
            self.settings["Move"] = move
        if zoom != None:
            self.settings["Zoom"] = zoom

    def UpdateCursor(self):
        if self.settings["Move"]:
            cursor = wx.StockCursor(wx.CURSOR_HAND)
            self.canvas.SetCursor(cursor)
        if self.settings["Zoom"]:
            cursor = wx.StockCursor(wx.CURSOR_CROSS)
            self.canvas.SetCursor(cursor)
        
    def GetSettings(self):
        """
        Returns the settigns of the current plot.
        """
        return self.settings
    

def startGUI():
    #Start GUI
    app = wx.App(False)
    gui = MainGUI(None, -1)
    app.MainLoop()

if __name__ == '__main__':
    startGUI()
