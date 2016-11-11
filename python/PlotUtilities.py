# import utilities for error repoorting etc
import GenUtilities as util
# use matplotlib for plotting
#http://matplotlib.org/faq/usage_faq.html#what-is-a-backend
import matplotlib.pyplot  as plt
# import numpy for array stuff
import numpy as np
# for color cycling
from itertools import cycle
import sys
import os 

g_font_label = 20
g_font_title = 22
g_font_legend = 18
g_tick_thickness = 3
g_tick_length = 12

# based on :http://stackoverflow.com/questions/18699027/write-an-upright-mu-in-matplotlib
#plt.rc('font', **{'sans-serif' : 'Arial', 'family' : 'sans-serif'})
# following line sets the mathtext to whatever is our font
plt.rcParams['mathtext.fontset'] = 'custom'
plt.rcParams['font.sans-serif'] = 'Georgia'
plt.rcParams['font.family'] = 'sans-serif'
# see: http://matplotlib.org/examples/pylab_examples/usetex_baseline_test.html
# this line makes it slow, etc plt.rcParams['text.usetex'] = True


def LegendAndSave(Fig,SaveName,loc="upper right",frameon=True,close=False):
    """
    Refreshes the legend on the given figure, saves it *without* closing
    by default

    Args:
        fig: the figure hangle to use
        SaveName: what to save this as 
        ... : see legend
    Returns:
        Nothing
    """
    legend(loc=loc,frameon=frameon)
    savefig(Fig,SaveName,close=close)

def LegendSaveAndIncr(Fig,Base,Number=0,ext=".pdf",**kwargs):
    """
    Same as legend and save, except takes a "base" 

    Args:
         Fig: See LegendAndSave
         Base:  base name to use
         Number: which figure iteration; we just count up
         ext: extension for the filename
         **kwargs: see LegendAndSave
    Returns:
        Number+1
    """
    LegendAndSave(Fig,Base+Number + ext,**kwargs)
    return Number + 1

def colorbar(label,labelpad=10,rotation=270):
    """
    Makes a simple color bar on the current plot, assuming that something
    like hist2d has already been called:
    
    Args:
        label: what to put on the colorpad
        labelpad,rotation: see cbar.set_label: 
 matplotlib.org/api/colorbar_api.html#matplotlib.colorbar.ColorbarBase.set_label
    """
    cbar = plt.colorbar()
    cbar.set_label(label,labelpad=labelpad,rotation=rotation)
    return cbar

def errorbar(x,y,yerr,label,fmt=None,alpha=0.1,ecolor='r',markersize=3.0,
             *args,**kwargs):
    # plot the data, a 'haze' around it, and dotted lines 
    if (fmt is None):
        fmt = "go"
    plt.fill_between(x, y - yerr,y + yerr, alpha=alpha,color=ecolor)
    plt.plot(x, y,fmt,label=label,markersize=markersize,*args,**kwargs)
    plt.plot(x, y+yerr,'b--')
    plt.plot(x, y-yerr,'b--')
    
def legend(fontsize=g_font_legend,loc=None,frameon=False,
           bbox_to_anchor=None,**kwargs):
    if (loc is None):
        loc = 'best'
    return plt.legend(fontsize=fontsize,loc=loc,frameon=frameon,
                      bbox_to_anchor=bbox_to_anchor,**kwargs)


def intLim(vals,xAxis=True,factor=0.5):
    # intelligently set the limits
    uni = np.unique(vals)
    maxV = vals[-1]
    minV = vals[0]
    # fudge factor is a factor of the minimum change
    if (uni.size == 1):
        # just a single point
        fudge = max(1,uni[0]*0.5)
    else:
        fudge = np.min(np.diff(uni))*0.5
    # set the limits
    if (xAxis):
        plt.gca().set_xlim(minV-fudge,maxV+fudge)
    else:
        plt.gca().set_ylim(minV-fudge,maxV+fudge)

def genLabel(func,label,fontsize=g_font_label,fontweight='bold',**kwargs):
    return func(label,fontsize=fontsize,fontweight=fontweight,**kwargs)
        
def xlabel(lab,ax=None,**kwargs):
    """
    Sets the x label 
    
    Args:
         lab: the abel to use
         ax: the axis to label. defaults to current
         **kwargs:  see genLabel
    Returns:
         Label
    """
    if (ax is None):
        ax = plt.gca()
    return genLabel(ax.set_xlabel,lab,**kwargs)

def ylabel(lab,ax=None,**kwargs):
    """
    Sets the y label
     
    Args: 
        See xlabel
    Returns:
        See xlabel
    """
    if (ax is None):
        ax = plt.gca()
    return genLabel(ax.set_ylabel,lab,**kwargs)

def zlabel(lab,ax=None,**kwargs):
    """
    Sets the z label
     
    Args: 
        See xlabel
    Returns:
        See xlabel
    """
    if (ax is None):
        ax = plt.gca()
    return genLabel(ax.set_zlabel,lab,**kwargs)

def title(lab,fontsize=g_font_title,**kwargs):
    plt.title(lab,fontsize=fontsize,**kwargs)


def lazyLabel(xlab,ylab,titLab,yrotation=90,titley=1.0,bbox_to_anchor=None,
              frameon=False,loc='best',axis_kwargs=dict(),legend_kwargs=dict(),
              useLegend=True,zlab=None,legendBgColor=None):
    """
    Easy method of setting the x,y, and title, and adding a legend
    
    Args:
         xlab: the x label to use
         ylab: the y label to use
         titLab: the title to use
         yrotation: angle to rotate. Default is vertical
         titley: where to position the title 
         frameon: for the legend; if true, adds a frame (and background)
         to the legend
         
         loc: legend location
         bbox_to_anchor: where to anchor the legend
         useLegend : boolean, true: add a legend
         zlab: the z label, for the third axis
         legendBgColor: the color for the legend, if present. Default is white
    Returns: 
         nothings
    """
    # set the labels and title
    xlabel(xlab,**axis_kwargs)
    ylabel(ylab,rotation=yrotation,**axis_kwargs)
    title(titLab,y=titley,**axis_kwargs)
    # set the font
    tickAxisFont(**axis_kwargs)
    # if we have a z or a legemd, set those too.
    if (zlab is not None):
        zlabel(zlab,**axis_kwargs)
    if (useLegend):
        leg = legend(frameon=frameon,loc=loc,**legend_kwargs)
        if (legendBgColor is not None):
            setLegendBackground(leg,legendBgColor)


def setLegendBackground(legend,color):
    """
    Sets the legend background to a particular color

    Args:
        legend: legend to set
        color: color to set legend to 
    
    Returns:
        This is a description of what is returned.
    """
    legend.get_frame().set_facecolor(color)

def tickAxisFont(fontsize=g_font_label,ax=None):
    if (ax is None):
        ax = plt.gca()
    ax.tick_params(axis='both', which='major', labelsize=fontsize)
    ax.tick_params(axis='both', which='minor', labelsize=fontsize)
    ax.xaxis.set_tick_params(width=g_tick_thickness,length=g_tick_length)
    ax.yaxis.set_tick_params(width=g_tick_thickness,length=g_tick_length)
    if (hasattr(ax, 'zaxis') and ax.zaxis is not None):
        ax.zaxis.set_tick_params(width=g_tick_thickness,length=g_tick_length)

def xTickLabels(xRange,labels,rotation='vertical',fontsize=g_font_label,
                **kwargs):
    tickLabels(xRange,labels,True,rotation=rotation,fontsize=fontsize,**kwargs)

def yTickLabels(xRange,labels,rotation='horizontal',fontsize=g_font_label,
                **kwargs):
    tickLabels(xRange,labels,False,rotation=rotation,fontsize=fontsize,**kwargs)

def tickLabels(xRange,labels,xAxis,tickWidth=g_tick_thickness,**kwargs):
    ax = plt.gca()
    if (xAxis):
        ax.set_xticks(xRange)
        ax.set_xticklabels(labels,**kwargs)
        mLocs = ['bottom','top']
    else:
        ax.set_yticks(xRange)
        ax.set_yticklabels(labels,**kwargs)
        mLocs = ['left','right']
    for l in mLocs:
        ax.spines[l].set_linewidth(tickWidth)
        ax.spines[l].set_linewidth(tickWidth)

def cmap(num,cmap = plt.cm.gist_earth_r):
    """
    Get a color map with the specified number of colors and mapping

    Args:
        num: number of colors
        cmap: color map to use, from plt.cm
    Returns:
        color map to use
    """
    return cmap(np.linspace(0, 1, num))

def useTex():
    # may need to install:
    # tlmgr install dvipng helvetic palatino mathpazo type1cm
    # http://stackoverflow.com/questions/14389892/ipython-notebook-plotting-with-latex
    from matplotlib import rc
    sys.path.append("/usr/texbin/")
    rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
    rc('text', usetex=True)

def addColorBar(cax,ticks,labels,oritentation='vertical'):
    cbar = plt.colorbar(cax, ticks=ticks, orientation='vertical')
    # horizontal colorbar
    cbar.ax.set_yticklabels(labels,fontsize=g_font_label)

# add a second axis to ax.
def secondAxis(ax,label,limits,secondY =True,color="Black",scale=None):
    if (scale is None):
        if secondY:
            scale = ax.get_yscale() 
        else:
            scale = ax.get_xscale()
    if(secondY):
        ax2 = ax.twinx()
        ax2.set_yscale(scale, nonposy='clip')
        ax2.set_ylim(limits)
        # set the y axis to the appropriate label
        lab = ylabel(label,ax=ax2)
        tickLabels = ax2.get_yticklabels()
        tickLims =  ax2.get_yticks()
    else:
        ax2 = ax.twiny()
        ax2.set_xscale(scale, nonposy='clip')
        ax2.set_xlim(limits)
        # set the x axis to the appropriate label
        lab = xlabel(label,ax=ax2)
        tickLabels = ax2.get_xticklabels()
        tickLims =  ax2.get_xticks()
    [i.set_color(color) for i in tickLabels]
    lab.set_color(color)
    tickAxisFont(ax=ax2)
    return ax2

def pm(stdOrMinMax,mean=None,fmt=".3g"):
    if (mean ==None):
        mean = np.mean(stdOrMinMax)
    arr = np.array(stdOrMinMax)
    if (len(arr) == 1):
        delta = arr[0]
    else:
        delta = np.mean(np.abs(arr-mean))
    return ("{:"+ fmt + "}+/-{:.2g}").format(mean,delta)

def savefig(figure,fileName,close=True,tight=True,**kwargs):
    # source : where to save the output iunder the output folder
    # filename: what to save the file as. automagically saved as high res pdf
    # override IO: if true, ignore any path infomation in the file name stuff.
    # close: if true, close the figure after saving.
    if (tight):
        plt.tight_layout(True)
    baseName = util.getFileFromPath(fileName)
    if ("." not in baseName):
        formatStr = ".svg"
        fullName = fileName + formatStr
    else:
        _,formatStr = os.path.splitext(fileName)
        fullName = fileName
    figure.savefig(fullName,format=formatStr[1:], 
                   dpi=figure.get_dpi(),**kwargs)
    if (close):
        plt.close(figure)

def figure(figsize=None,xSize=10,ySize=8,dpi=100):
    """
    wrapper for figure, allowing easier setting I think

    Args:
        figsize: tuple of (x,y). If none, uses xsize and ysize
        xSize: x size of figure in inhes
        ySize: y size of figure in inches
        dpi: dots per inch
    Returns:
        figure it created
    """
    if (figsize is not None):
        xSize = figsize[0]
        ySize = figsize[1]
    return  plt.figure(figsize=(xSize,ySize),dpi=dpi)

def getNStr(n,space = " "):
    return space + "n={:d}".format(n)

# legacy API. plan is now to mimic matplotlib 
def colorCyc(num,cmap = plt.cm.winter):
    cmap(num,cmap)
def pFigure(xSize=10,ySize=8,dpi=100):
    return figure(xSize,ySize,dpi)
def saveFigure(figure,fileName,close=True):
    savefig(figure,fileName,close)
