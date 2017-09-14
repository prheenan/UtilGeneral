# force floating point division. Can still use integer with //
from __future__ import division
# other good compatibility recquirements for python3
from __future__ import absolute_import
from __future__ import print_function
from __future__ import unicode_literals
# This file is used for importing the common utilities classes.
import numpy as np
import matplotlib.pyplot as plt
import sys,matplotlib
from GeneralUtil.python.PlotUtilities import *

# XXX move to utility class?
default_font_dict = dict(fontsize=g_font_label,
                         fontweight='bold',
                         family="sans",
                         color='k',
                         horizontalalignment='center',
                         verticalalignment='lower',
                         bbox=dict(color='w',alpha=0,pad=0))
    
def _annotate(ax,s,xy,**font_kwargs):
    """
    Adds a simpel text annotation. 
    
    Args:
        ax: where to add the annotation
        s: the string
        xy: the location of the string. 
        **font_kwargs: anything accepted by ax.annotate. defaults are added
        if they dnot exist.
    Returns:
        ax.annotate object 
    """
    # add in defaults if they dont exist    
    for k,v in default_font_dict.items():
        if k not in font_kwargs:
            font_kwargs[k] = v
    # POST: all default added             
    return ax.annotate(s=s, xy=xy,**font_kwargs)
    
def relative_annotate(ax,s,xy,xycoords='axes fraction',**font_kwargs):
    """
    see: _annotate, except xy are given in 0-1 from bottom left ('natural')
    """
    return _annotate(ax,s,xy,xycoords=xycoords,**font_kwargs)
    
def add_rectangle(ax,xlim,ylim,fudge_pct=0,facecolor="None",linestyle='-',
                  edgecolor='k',linewidth=0.75,zorder=10,**kw):
    """
    Ease-of-use function to add a rectangle to ax
    
    Args:
        ax: the axis to add to
        <x/y>_lim: limits of the rectangle
        fudge_pct: how much to add, as a fraction of the axis range. 
        remainder: see  matplotlib.patches.Rectangle
    Returns : 
        the rectangle added 
    """
    x_min,x_max = min(xlim),max(xlim)
    y_min,y_max = min(ylim),max(ylim)
    fudge = (x_max-x_min) * fudge_pct
    xy = [x_min,y_min]
    width = (x_max-x_min) + fudge
    height = (y_max-y_min) + fudge
    r = matplotlib.patches.Rectangle(xy=xy,width=width,height=height,
                                     facecolor=facecolor,linestyle=linestyle,
                                     edgecolor=edgecolor,zorder=zorder,
                                     linewidth=linewidth,**kw)
    ax.add_patch(r)  
    return r 