# import utilities for error repoorting etc
import GeneralUtil.python.GenUtilities as util
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
g_font_tick = 16
g_font_legend = 18
g_tick_thickness = 1.75
g_tick_length = 10
g_minor_tick_width = 1.25
g_minor_tick_length= 4
# make the hatches larges
import matplotlib as mpl
mpl.rcParams['hatch.linewidth'] = 4
# based on :http://stackoverflow.com/questions/18699027/write-an-upright-mu-in-matplotlib
# following line sets the mathtext to whatever is our font
plt.rcParams['font.sans-serif'] = 'Arial'
plt.rcParams['font.family'] = 'sans-serif'
# see: http://matplotlib.org/examples/pylab_examples/usetex_baseline_test.html
# this line makes it slow, etc plt.rcParams['text.usetex'] = True
from string import ascii_lowercase
from matplotlib.ticker import LogLocator,MaxNLocator
# for the zoom effect
from mpl_toolkits.axes_grid1.inset_locator import BboxPatch, BboxConnector,\
    BboxConnectorPatch
from matplotlib.transforms import Bbox, TransformedBbox, \
    blended_transform_factory


import string
from itertools import cycle
from six.moves import zip

def label_axes(fig, labels=None, loc=None, add_bold=False,
               axis_func= lambda x: x,**kwargs):
    """
    Walks through axes and labels each.
    kwargs are collected and passed to `annotate`
    Parameters
    credit: 

    gist.github.com/tacaswell/9643166

    and

    stackoverflow.com/questions/22508590/enumerate-plots-in-matplotlib-figure
    ----------
    fig : Figure
         Figure object to work on
    labels : iterable or None
        iterable of strings to use to label the axes.
        If None, lower case letters are used.
    loc : len=2 tuple of floats (or list of them, one per axis)
        Where to put the label in axes-fraction units
    """
    if labels is None:
        labels = ["{:s}".format(s) for s in string.uppercase]
    # re-use labels rather than stop labeling
    labels = cycle(labels)
    n_ax = fig.axes
    if loc is None:
        loc = (-0.15, 1.05)
    if (isinstance(loc,tuple)):
        loc = [loc for _ in n_ax]
    for ax, lab,loc_tmp in zip(axis_func(fig.axes), labels,loc):
        ax.annotate(lab, xy=loc_tmp,
                    xycoords='axes fraction',**kwargs)

def label_tom(fig,labels=None, loc=None,fontsize=g_font_legend,**kwargs):
    """
    labels each subplot in fig

    fig : Figure
         Figure object to work on

    loc,labels : see label_axes
    others: passedto text arguments
    """
    text_args = dict(horizontalalignment='center',
                     verticalalignment='center',
                     fontweight='bold',
                     fontsize=fontsize,**kwargs)
    label_axes(fig,labels=labels,loc=loc,**text_args)
    
def FormatImageAxis(ax=None):
    """
    Formats the given (default current) axis for displaying an image 
    (no ticks,etc)

    Args:
         ax: the axis to format
         aspect: passed to the axis
    """
    if (ax is None):
        ax = plt.gca()
    # Turn off axes and set axes limits
    ax.axis('off')

def _remove_labels(ax):
    ax.set_ticklabels([])

def _remove_grid(ax):
    ax.set_visible(False)

def no_y_label(ax=None):
    ax = plt.gca() if ax is None else ax
    _remove_labels(ax.get_yaxis())

def no_x_label(ax=None):
    ax = plt.gca() if ax is None else ax
    _remove_labels(ax.get_xaxis())

def no_x_grid(ax=None):
    ax = plt.gca() if ax is None else ax
    _remove_grid(ax.get_xaxis())

def no_y_grid(ax=None):
    ax = plt.gca() if ax is None else ax
    _remove_grid(ax.get_yaxis())

def no_x_axis(ax=plt.gca()):
    ax.xaxis.set_visible(False)
    
def no_y_axis(ax=plt.gca()):
    ax.yaxis.set_visible(False)    

def no_x_anything(ax=plt.gca()):
    no_x_axis(ax)
    no_x_grid(ax)
    no_x_label(ax)
    
def no_y_anything(ax=plt.gca()):
    no_y_axis(ax)
    no_y_grid(ax)    
    no_y_label(ax)    

def x_label_on_top(ax=plt.gca()):
    ax.xaxis.set_label_position('top') 
    ax.xaxis.set_tick_params(labeltop='on',labelbottom='off')



def autolabel(rects,label_func=lambda i,r: "{:.3g}".format(r.get_height()),
              x_func=None,y_func=None,fontsize=g_font_legend,**kwargs):
    """
    Attach a text label above each bar displaying its height

    Args:
        rects: return from ax.bar
        label_func: takes a rect and its index, returs the label
    Returns:
        nothing, but sets text labels
    """
    ax = plt.gca()
    if (x_func is None):
        x_func = lambda i,rect: rect.get_x() + rect.get_width()/2.
    if (y_func is None):
        y_func = lambda i,rect: rect.get_height() * 1.2
    for i,rect in enumerate(rects):
        height = rect.get_height()
        text = label_func(i,rect)
        x = x_func(i,rect)
        y = y_func(i,rect)
        ax.text(x,y,text,ha='center', va='bottom',fontsize=fontsize,**kwargs)

def AddSubplotLabels(fig=None,axs=None,skip=0,
                     xloc=-0.03,yloc=1,fontsize=30,fontweight='bold',
                     bbox=dict(facecolor='none', edgecolor='black',
                               boxstyle='round,pad=0.2')):
    """
    Adds labels to current subplot in their fig.axes order

    Args:
        fig: where to add; adds sequentially to all subplots, if no axs
        axs: if present, only add to these subplots)
        All the rest: see ax.text arguments
    """
    # get the axes we are adding...
    if (axs is None):
        if (fig is None):
            fig = plt.gcf()
        axs = fig.axes
    lim = len(axs)
    labels = [c for c in ascii_lowercase[skip:][:lim]]
    for ax,label in zip(axs,labels):
        ax.text(xloc, yloc, label, transform=ax.transAxes,
                fontsize=fontsize, fontweight=fontweight, va='top', ha='right',
                bbox=bbox)

def scale_bar_x(x,y,s,**kwargs):
    """
    makes an x scale bar

    Args:
        x: where the x center of the text should be
        y: where the y center of the text should be
        **kwargs: passed to _scale_bar
    """
    _scale_bar(x=x,y=y,s=s,height=0,**kwargs)

def _scale_bar(x,y,s,ax=None,width=None,height=None,color='w',
               bg_color='k',linewidth=25,fontsize=25,**kwargs):
    """
    makes a scale bar

    Args:
        x: see scale_bar_x 
        y: see scale_bar_x 
        ax: where to plot
        height,width: of the scale bar. 
        color: of the font
        bg_color: of the backround for the scale bar
        linewidth: for the plotted line (which is really the background)
        **kwargs: passed as font arguments to annotate (e.g. rotation, for y)
    """
    if (ax is None):
        ax = plt.gca()
    xlim,ylim = ax.get_xlim(),ax.get_ylim()
    default_length_pct = 0.1
    if (width is None):
        width = (xlim[1]-xlim[0]) * default_length_pct
    if (height is None):
        height = (ylim[1]-ylim[0]) * default_length_pct
    box_props = dict(color=bg_color,pad=0,**kwargs)
    font_kwargs = dict(color='w',horizontalalignment='center',
                       verticalalignment='center',fontsize=fontsize)
    t = ax.annotate(s, xy=(x,y),bbox=box_props,
                    **font_kwargs)
    x_draw = [x-width/2,x+width/2]
    y_draw = [y-height/2,y+height/2]
    plt.plot(x_draw,y_draw,color=bg_color,linewidth=linewidth)


def _LegendAndSave(Fig,SaveName,loc="upper right",frameon=True,close=False,
                  tight=True,**kwargs):
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
    savefig(Fig,SaveName,close=close,tight=tight,**kwargs)

def legend_and_save(Fig,Base,Number=0,ext=".png",**kwargs):
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
    _LegendAndSave(Fig,Base+str(Number) + ext,**kwargs)
    return Number + 1

def colorbar(label,labelpad=25,rotation=270,fontsize=g_font_legend,
             fontsize_ticks=g_font_legend,
             bar_kwargs=dict()):
    """
    Makes a simple color bar on the current plot, assuming that something
    like hist2d has already been called:
    
    Args:
        label: what to put on the colorpad
        labelpad,rotation,fontsize: see cbar.set_label: 
 matplotlib.org/api/colorbar_api.html#matplotlib.colorbar.ColorbarBase.set_label
    """
    cbar = plt.colorbar(**bar_kwargs)
    cbar.set_label(label,labelpad=labelpad,rotation=rotation,fontsize=fontsize)
    cbar.ax.tick_params(labelsize=fontsize_ticks)
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
           bbox_to_anchor=None,fancybox=False,**kwargs):
    if (loc is None):
        loc = 'best'
    return plt.legend(fontsize=fontsize,loc=loc,frameon=frameon,
                      fancybox=fancybox,bbox_to_anchor=bbox_to_anchor,**kwargs)


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
              frameon=False,loc='best',axis_kwargs=dict(),tick_kwargs=dict(),
              legend_kwargs=dict(),title_kwargs=dict(),legend_width=5,
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
    title(titLab,y=titley,**title_kwargs)
    # set the font
    tickAxisFont(**tick_kwargs)
    # if we have a z or a legemd, set those too.
    if (zlab is not None):
        zlabel(zlab,**axis_kwargs)
    if (useLegend):
        leg = legend(frameon=frameon,loc=loc,**legend_kwargs)
        if (legendBgColor is not None):
            setLegendBackground(leg,legendBgColor)

def set_legend_kwargs(ax=None,linewidth=2,background_color='w',
                      color='k',**kwargs):
    if (ax is None):
        ax = plt.gca()
    leg = ax.get_legend()
    frame = leg.get_frame()
    setLegendBackground(leg,background_color)
    frame.set_linewidth(linewidth)
    frame.set_edgecolor(color)

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

def axis_locator(ax,n_major,n_minor):
    scale = ax.get_scale()
    if (scale == 'log'):
        ax.set_major_locator(LogLocator(numticks=n_major))
        ax.set_minor_locator(LogLocator(numticks=n_minor))
    else:
        ax.set_major_locator(MaxNLocator(n_major))
        ax.set_minor_locator(MaxNLocator(n_minor))
    
    
def tick_axis_number(ax=None,num_x_major=5,num_x_minor=None,num_y_major=5,
                     num_y_minor=None):
    """
    Sets the locators on the x and y ticks

    Args:
        ax: what axis to use
        num_<x/y>_major: how many major ticks to put on the x,y
        num_<x/y>_minor: how many minor ticks to put on the x,y
    Returns:
        Nothing
    """
    if (ax is None):
        ax = plt.gca()
    if (num_x_minor is None):
        num_x_minor = 2 * num_x_major
    if (num_y_minor is None):
        num_y_minor = 2 * num_y_major
    axis_locator(ax.xaxis,num_x_major,num_x_minor)
    axis_locator(ax.yaxis,num_y_major,num_y_minor)
    
def tickAxisFont(fontsize=g_font_tick,
                 major_tick_width=g_tick_thickness,
                 major_tick_length=g_tick_length,
                 minor_tick_width=g_minor_tick_width,
                 minor_tick_length=g_minor_tick_length,
                 ax=None,common_dict=None,axis='both',bottom=True,
                 top=True,left=True,right=True):
    """
    sets the tick axis font and tick sizes

    Args:
         ax: what tick to use 
         fontsize: for the ticks
         <major/minor>_tick_<width/length>: the length or width for the minor 
         or major ticks. 
    """
    if (ax is None):
        ax = plt.gca()
    common_dict = dict(direction='in',
                       axis=axis,bottom=bottom,top=top,right=right,left=left)
    ax.tick_params(length=major_tick_length, width=major_tick_width,
                   labelsize=fontsize,which='major',**common_dict)
    ax.tick_params(length=minor_tick_length, width=minor_tick_width,
                   which='minor',**common_dict)
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

def secondAxis(ax,label,limits,secondY =True,color="Black",scale=None):
    """
    Adds a second axis to the named axis

    Args:
        ax: which axis to use
        label: what to label the new axis
        limits: limits to put on the new axis (data units)
        secondY: if true, uses the y axis, else the x
        color: what to color the new axis
        scale: for the axis. if None, defaults to the already present one
    Returns:
        new axis
    """
    current = ax
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
        axis_opt = dict(axis='y',left=False)
        other_axis_opt = dict(axis='y',right=False)
        ax.yaxis.tick_left()
    else:
        ax2 = ax.twiny()
        ax2.set_xscale(scale, nonposy='clip')
        ax2.set_xlim(limits)
        # set the x axis to the appropriate label
        lab = xlabel(label,ax=ax2)
        tickLabels = ax2.get_xticklabels()
        tickLims =  ax2.get_xticks()
        axis_opt = dict(axis='x',bottom=False)
        other_axis_opt = dict(axis='x',top=False)
    [i.set_color(color) for i in tickLabels]
    lab.set_color(color)
    current.tick_params(**other_axis_opt)
    tickAxisFont(ax=ax2,**axis_opt)
    plt.sca(current)
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

def savefig(figure,fileName,close=True,tight=True,subplots_adjust=None,
            **kwargs):
    """
    Saves the given figure with the options and filenames
    
    Args:
        figure: what figure to use
        fileName: what to save the figure out as
        close: if true (def), clsoes the figure
        tight: if true, reverts to the tight layour
        subplot_adjust: if not none, a dictionary to give to plt.subplots_adjust
        **kwargs: passed to figure savefig
    Returns:
        nothing
    """
    if (tight):
        plt.tight_layout(True)
    if (subplots_adjust is not None):
        plt.subplots_adjust(**subplots_adjust)
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

def figure(figsize=None,xSize=10,ySize=8,dpi=300):
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

def connect_bbox(bbox1, bbox2,
                 loc1a, loc2a, loc1b, loc2b,
                 prop_lines, prop_patches=None):
    """
    connect the two bboxes see zoom_effect01(ax1, ax2, xmin, xmax)
    """
    if prop_patches is None:
        prop_patches = prop_lines.copy()
    c1 = BboxConnector(bbox1, bbox2, loc1=loc1a, loc2=loc2a, **prop_lines)
    c1.set_clip_on(False)
    c2 = BboxConnector(bbox1, bbox2, loc1=loc1b, loc2=loc2b, **prop_lines)
    c2.set_clip_on(False)
    bbox_patch1 = BboxPatch(bbox1, color='k',**prop_patches)
    bbox_patch2 = BboxPatch(bbox2, color='w',**prop_patches)
    p = BboxConnectorPatch(bbox1, bbox2,
                           # loc1a=3, loc2a=2, loc1b=4, loc2b=1,
                           loc1a=loc1a, loc2a=loc2a, loc1b=loc1b, loc2b=loc2b,
                           **prop_patches)
    p.set_clip_on(False)

    return c1, c2, bbox_patch1, bbox_patch2, p


def zoom_effect01(ax1, ax2, xmin, xmax, **kwargs):
    """
    connect ax1 & ax2. The x-range of (xmin, xmax) in both axes will
    be marked.  The keywords parameters will be used to create
    patches.

    Args:
        ax1 : the main axes
        ax1 : the zoomed axes
        (xmin,xmax) : the limits of the colored area in both plot axes.
    """

    trans1 = blended_transform_factory(ax1.transData, ax1.transAxes)
    trans2 = blended_transform_factory(ax2.transData, ax2.transAxes)

    bbox = Bbox.from_extents(xmin, 0, xmax, 1)

    mybbox1 = TransformedBbox(bbox, trans1)
    mybbox2 = TransformedBbox(bbox, trans2)

    prop_patches = kwargs.copy()
    alpha_path = 0.2
    alpha_line = 0.7
    line_width = 3
    prop_patches["ec"] = "none"
    prop_patches["alpha"] = alpha_path
    prop_lines = dict(color='k',alpha=alpha_line,linewidth=line_width,**kwargs)
    c1, c2, bbox_patch1, bbox_patch2, p = \
        connect_bbox(mybbox1, mybbox2,
                     loc1a=3, loc2a=2, loc1b=4, loc2b=1,
                     prop_lines=prop_lines, prop_patches=prop_patches)

    ax1.add_patch(bbox_patch1)
    ax2.add_patch(bbox_patch2)
    ax2.add_patch(c1)
    ax2.add_patch(c2)
    ax2.add_patch(p)

    return c1, c2, bbox_patch1, bbox_patch2, p


# legacy API. plan is now to mimic matplotlib 
def colorCyc(num,cmap = plt.cm.winter):
    cmap(num,cmap)
def pFigure(xSize=10,ySize=8,dpi=100):
    return figure(xSize,ySize,dpi)
def saveFigure(figure,fileName,close=True):
    savefig(figure,fileName,close)
