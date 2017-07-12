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

default_font_dict = dict(fontsize=g_font_label,
                         fontweight='bold',
                         color='k',
                         horizontalalignment='center',
                         verticalalignment='lower',
                         bbox=dict(color='w',alpha=0,pad=0))

def round_to_n_sig_figs(x,n=1):
    """
    Rounds 'x' to n significant figures

    Args:
         x: what to round
         n: how many sig figs (e.g. n=1 means 51 --> 50, etc)
    Returns: rounded number 
    """
    return round(x, (n-1)-int(np.floor(np.log10(abs(x)))))


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
    
def _scale_bar_and_ticks(ax,axis,lim,is_x=True,**kwargs):
    """
    convenience wrapper for create a scale bar with convenient ticks 
    
    Args:
        ax: like plt.gca()
        axis: something we can use 'set_major.minor_locator' on
        lim: the limits of the axis
    Returns:
        nothing
    """
    box,x,y = _scale_bar(ax=ax,**kwargs)
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
    
def _y_scale_bar_and_ticks(ax=plt.gca(),**kwargs):
    """
    Convenience wrapper to make a scale bar and ticks
    
    Args:
        kwargs: passed to _scale_bar_and_ticks
    Returns:
        nothing
    """    
    _scale_bar_and_ticks(ax,ax.yaxis,ax.get_ylim(),is_x=False,**kwargs)   

def _x_scale_bar_and_ticks(ax=plt.gca(),**kwargs):
    """
    Convenience wrapper to make a scale bar and ticks
    
    Args:
        kwargs: passed to _scale_bar_and_ticks
    Returns:
        nothing
    """
    _scale_bar_and_ticks(ax,ax.xaxis,ax.get_xlim(),**kwargs)   
    
def rel_to_abs(ax,x,is_x):
    if (is_x):
        lim = ax.get_xlim()
    else:
        lim = ax.get_ylim()
    absolute = lim[0] + (lim[1] - lim[0]) * x
    return absolute
    
    
def offsets_and_ranges(width,height,offset_x,offset_y):
    bar_offset_x = width/2
    bar_offset_y = height/2 
    text_offset_x = offset_x  
    text_offset_y = offset_y
    xy_text = [text_offset_x,text_offset_y]   
    xy_line =  [ [text_offset_x - bar_offset_x,text_offset_y - bar_offset_y],
                [text_offset_x + bar_offset_x,text_offset_y + bar_offset_y]]
    return xy_text,xy_line                
    
def unit_format(val,unit,fmt="{:.0f}"):
    return (fmt + " {:s}").format(val,unit) 
    
def x_scale_bar_and_ticks(unit,width,offset_x,offset_y,ax=plt.gca(),
                          fmt="{:.0f}",**kwargs):
    xy_text,xy_line = offsets_and_ranges(width=width,height=0,
                                        offset_x=offset_x,offset_y=offset_y)
    text = unit_format(width,unit,fmt)                                    
    return _x_scale_bar_and_ticks(ax=ax,xy_text=xy_text,xy_line=xy_line,
                                  text=text,**kwargs)
                                  
def y_scale_bar_and_ticks(unit,height,offset_x,offset_y,ax=plt.gca(),
                          fmt="{:.0f}",**kwargs):
    xy_text,xy_line = offsets_and_ranges(width=0,height=height,
                                        offset_x=offset_x,offset_y=offset_y)
    text = unit_format(height,unit,fmt)                                                                            
    return _y_scale_bar_and_ticks(ax=ax,xy_text=xy_text,xy_line=xy_line,
                                  text=text,**kwargs)       
                                  

def crossed_x_and_y(offset_x,offset_y,x_kwargs,y_kwargs):
    assert ("height" in y_kwargs.keys()) , "Height not specified"
    assert ("width" in x_kwargs.keys()) , "Width not specified"
    width,height = x_kwargs['width'],y_kwargs['height']
    font_kwargs_y = default_font_dict
    font_kwargs_y['horizontalalignment'] = 'right'
    print(offset_x,offset_y)
    x_scale_bar_and_ticks(offset_x=offset_x,offset_y=offset_y,**x_kwargs)                                       
    y_scale_bar_and_ticks(offset_x=offset_x-width/2,offset_y=offset_y+height,
                          font_kwargs=font_kwargs_y,**y_kwargs)                                       
    
def _scale_bar(text,xy_text,xy_line,ax=plt.gca(),
               line_kwargs=dict(linewidth=1,color='k'),
               font_kwargs=default_font_dict):
    t = ax.annotate(s=text, xy=xy_text,**font_kwargs)
    x_draw = [x[0] for x in xy_line]
    y_draw = [x[1] for x in xy_line]
    print(x_draw,y_draw,xy_text)
    plt.plot(x_draw,y_draw,**line_kwargs)
    return t,x_draw,y_draw
