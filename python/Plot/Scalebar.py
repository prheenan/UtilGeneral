# force floating point division. Can still use integer with //
from __future__ import division
# other good compatibility recquirements for python3
from __future__ import absolute_import
from __future__ import print_function
from __future__ import unicode_literals
# This file is used for importing the common utilities classes.
import numpy as np
import matplotlib.pyplot as plt
import sys

from GeneralUtil.python.PlotUtilities import *

def round_to_n_sig_figs(x,n=1):
    """
    Rounds 'x' to n significant figures

    Args:
         x: what to round
         n: how many sig figs (e.g. n=1 means 51 --> 50, etc)
    Returns: rounded number 
    """
    return round(x, (n-1)-int(np.floor(np.log10(abs(x)))))

def make_scale_bar(mult=1000,unit="ms",y_frac=0.2,x_frac=0.2,width=0.2,
                   fmt="{:.0f}",label_sig_figs=2,y_label_frac=0.15,
                   fontsize=g_font_legend,is_x=True,**kwargs):
    """
    Makes an (x) scale bar. All parameters are relative to the graph size

    Args:
        mult: for the *label only*, what should we multiply the width to 
        conver to <unit>

        unit: of the label. width * diff(plt.xlim()) * mult should be in this
        unit

        <x/y>_frac: the fraction of the plot size to use for the width, height
       
        fmt: the format string to use on  width * diff(plt.xlim()) * mult. 
        Defaults to juse a round number
 
        label_sig_figs: how many significant figures should be used 

        y_height_frac: fraction of the y limits that the scale bar should be
        under
        
        is_x: if true, then this is an x scale bar 

        kwargs: passed to scale_bar_x
    Returns:
        tuple of <the text box, and the x and y coordinates of the line>
    """
    xlim = plt.xlim()
    x_full = abs(np.diff(xlim))[0]
    if (is_x):            
        width = width * x_full
    else:
        width = 0
    ylim = plt.ylim()
    y_diff = abs(np.diff(ylim))
    y_full = np.diff(ylim)[0]
    # get the location of the text...
    y = np.max(ylim) - abs(y_full)*y_frac
    x = np.min(xlim) + abs(x_full) * x_frac
    fmt_str = (fmt + "{:s}")
    height = y_full*y_label_frac    
    if (is_x):                
        value = width*mult
    else:
        value = height*mult    
    s = fmt_str.format(round_to_n_sig_figs(value,n=label_sig_figs),unit)        
    kwarg_dict = dict(x=x,y=y,s=s,width=width,fontsize=fontsize,
                      style_line=True,height=height,
                      **kwargs)
    box,x,y = _scale_bar(**kwarg_dict)
    return box,x,y

def _get_tick_locator_fixed(offset,width,lim=plt.xlim()):
    """
    given a (data-units) offset and width, returns tick so that
    (1) offset is a tick
    (2) each offset +/- (n * width) for n an integer within lim is a tick.

    Useful for matching ticks to a scale bar 

    Args:
         offset: point which should have a tick on it
         width: data units, length between ticks
         lim: to determine where the ticks should be 
    Returns:
         FixedLocator parameter
    """
    xmin,xmax = lim
    # determine how many widths to go before and after
    n_widths_before = int(np.ceil(abs((offset-xmin)/width)))
    width_before = n_widths_before * width
    n_widths_after = int(np.ceil(abs((xmax-offset)/width)))
    width_after = n_widths_after * width
    ticks_after = np.arange(start=offset,stop=offset+(width_after+width),
                            step=width)
    ticks_before = np.arange(start=offset,stop=offset-(width_before+width),
                             step=-width)
    ticks = list(ticks_before) + list(ticks_after)
    locator = FixedLocator(locs=ticks, nbins=None)
    return locator
    
def _scale_bar_and_ticks(axis,lim,is_x=True,**kwargs):
    """
    convenience wrapper for create a scale bar with convenient ticks 
    
    Args:
        axis: something we can use 'set_major.minor_locator' on
        lim: the limits of the axis
    Returns:
        nothing
    """
    box,x,y = make_scale_bar(is_x=is_x,**kwargs)
    if (is_x):       
        tick_spacing = abs(np.diff(x))
        offset = min(x)
    else:
        tick_spacing = abs(np.diff(y))
        offset = min(y)
    locator_x = _get_tick_locator_fixed(offset=offset,width=tick_spacing,
                                        lim=lim)
    locator_minor_x = _get_tick_locator_fixed(offset=offset+tick_spacing/2,
                                              width=tick_spacing,lim=lim)
    axis.set_major_locator(locator_x)
    axis.set_minor_locator(locator_minor_x)    
    
def y_scale_bar_and_ticks(ax=plt.gca(),**kwargs):
    """
    Convenience wrapper to make a scale bar and ticks
    
    Args:
        kwargs: passed to _scale_bar_and_ticks
    Returns:
        nothing
    """    
    _scale_bar_and_ticks(ax.yaxis,ax.get_ylim(),is_x=False,**kwargs)   

def x_scale_bar_and_ticks(ax=plt.gca(),**kwargs):
    """
    Convenience wrapper to make a scale bar and ticks
    
    Args:
        kwargs: passed to _scale_bar_and_ticks
    Returns:
        nothing
    """
    _scale_bar_and_ticks(ax.xaxis,ax.get_xlim(),**kwargs)   
 

def _scale_bar(x,y,s,ax=None,width=None,height=None,color='w',
               bg_color='k',linewidth=1.25,fontsize=g_font_label,
               fontweight='bold',horizontalalignment='center',
               verticalalignment='center',
               style_line=False,**kwargs):
    """
    makes a scale bar

    Args:
        x: see scale_bar_x 
        y: see scale_bar_x 
        ax: where to plot
        height,width: of the scale bar. 
        color: of the font
        bg_color: of the backround for the scale bar
        linewidth: for the plotted line, if style_line
        **kwargs: passed as font arguments to annotate (e.g. rotation, for y)
    returns:
        tuple of the text box, and the x and y coordinates of the 
        'scalebar' 
    """
    if (ax is None):
        ax = plt.gca()
    xlim,ylim = ax.get_xlim(),ax.get_ylim()
    default_length_pct = 0.2
    if (width is None):
        width = (xlim[1]-xlim[0]) * default_length_pct
    if (height is None):
        height = (ylim[1]-ylim[0]) * default_length_pct
    # if we are just plotting a line under the text, then the 
    # background of the text is transparent
    if (not style_line):
        box_props = dict(color=bg_color,alpha=1,pad=0,**kwargs)
        fontcolor='w'
    else:
        box_props = dict(color='w',alpha=0,pad=0,**kwargs)
        fontcolor='k'
    font_kwargs = dict(color=fontcolor,horizontalalignment=horizontalalignment,
                       fontweight=fontweight,
                       verticalalignment=verticalalignment,fontsize=fontsize)
    t = ax.annotate(s, xy=(x,y),bbox=box_props,
                    **font_kwargs)
    t = None
    x_draw = [x-width/2,x+width/2]
    point_y1 = y-height/2
    point_y2 = y+height/2
    y_draw = [point_y1,point_y2]
    if not style_line:
        y1 = [point_y1 for _ in x_draw]
        y2 = [point_y2 for _ in x_draw]
        plt.fill_between(x_draw,y1=y1,y2=y2,color='k')
    else:
        plt.plot(x_draw,[point_y1,point_y1],color='k',linewidth=linewidth)
    return t,x_draw,y_draw
