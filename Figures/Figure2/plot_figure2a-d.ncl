begin

    ; data_path = "/Users/Komputer/paper_results_nn/Figures/Figure2/"
    data = addfile("Figure2.nc", "r")  
    maxlat = 31;
    lat = data->latitude
    ; print(lat)
    lon = data->longitude

    tsr_in = data->tsr 
    tsr_era_in = data->tsr_era  
    rmse_toa = data->rmse_tsr 
    print(getvardimnames(tsr_era_in) + " : " + dimsizes(tsr_era_in))
    tsr = dim_avg_n(tsr_in, 0)
    tsr_era = dim_avg_n(tsr_era_in, 0)
    tsr!0="lat"
    tsr!1="lon"
    tsr&lon=lon
    tsr&lat=lat
    tsr&lon@units="degrees_east"
    tsr&lat@units="degrees_north"
    copy_VarCoords(tsr,tsr_era)
    copy_VarCoords(tsr,rmse_toa)

    ; tsr_in!0 = "time"
    ; tsr_in!1="lat"
    ; tsr_in!2="lon"
    ; tsr_in&time = new(120,float)
    ; tsr_in&lon=lon
    ; tsr_in&lat=lat
    ; copy_VarCoords(tsr_in,tsr_era_in)
    mbe_toa = tsr - tsr_era
    copy_VarCoords(tsr,mbe_toa)

    ;  calculate global mean
    re             = 6.37122e06           ; earth radius [m]
    rad            = 4.0*atan(1.0)/180.0          ; get radiance
    clat           = cos(lat*rad)         ; cosine of latitude

    dlon           = (lon(2) - lon(1))    ; assume dlon is constant
    dlat           = (lat(2) - lat(1))    ; assume dlat is constant

    dx             = dlon*clat            ; dx at each latitude
    dy             = dlat*re*rad          ; dy is costant
    area           = dy*dx                ; area(nlat)
    opt_wgt        = 0    ;0-calculate non-missing data

    tsr_avg = wgt_areaave(tsr,area,1.0,opt_wgt)
    tsr_era_avg = wgt_areaave(tsr_era,area,1.0,opt_wgt)
    mbe_toa_avg = wgt_areaave(mbe_toa,area,1.0,opt_wgt)
    rmse_toa_avg = wgt_areaave(rmse_toa,area,1.0,opt_wgt)

    reg_mean = new(4,float)
    reg_mean(0) = tsr_avg
    reg_mean(1) = tsr_era_avg
    reg_mean(2) = mbe_toa_avg
    reg_mean(3) = rmse_toa_avg
    reg_mean = decimalPlaces(reg_mean,2,True)  

    ; x     = ispan(0,dimsizes(tsr)-1,1)*1.
    ; rc    = regline(x,ts)  
    ; data      = new ( (/2,dimsizes(tsr)/), typeof(tr))
    ; data(0,:) = tsr
    ; data(1,:) = rc*(x-rc@xave) + rc@yave


    wks = gsn_open_wks("pdf","Figure2a-d")             ; send graphics to PNG file
    plot = new(4,graphic)

    res            = True                         ; plot mods desired
    res@gsnPolar   = "NH"                         ; specify the hemisphere
    res@mpMinLatF  = 60                         ; minimum lat to plot
    ; res@cnFillPalette        = colors
    res@cnFillOn             = True               ; turns on the color
    res@mpFillOn             = False              ; turns off continent gray
    res@cnLinesOn            = False              ; turn off contour lines
    ; res@gsnAddCyclic = False

    res@gsnDraw      =  False                   ; do not draw the plot
    res@gsnFrame     =  False

    res@tmXBLabelFont = 22
    res@tmXBLabelFontThicknessF = 2.
    res@tmXBLabelFontHeightF =0.05
    res@tmXBLabelStride = 2
    res@tmYLLabelFont = 22
    res@tmYLLabelFontThicknessF = 2.
    res@tmYLLabelFontHeightF =0.05
    res@tmBorderThicknessF = 3

    res@gsnStringFontHeightF = 0.035
    res@lbLabelFontHeightF = 0.035

    ; res@mpShapeMode  = "FreeAspect"
    ; res@vpHeightF = 1.0
    ; res@vpWidthF = 1.0

    ; res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    ; res@cnMinLevelValF       = -24                 ; set min contour level
    ; res@cnMaxLevelValF       = 24                ; set max contour level
    ; gsn_define_colormap(wks, "BlueDarkRed18")
    res@txFont   = "helvetica-bold"
    res@gsnStringFontHeightF = 0.035
        res@gsnLeftString = "(a) TSR NN"
    res@gsnRightString = reg_mean(0) + " ~F22~W/m~S~2~"
    plot(0) = gsn_csm_contour_map_polar(wks,tsr,res)

    ; res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    ; res@cnMinLevelValF       = -24                 ; set min contour level
    ; res@cnMaxLevelValF       = 24                ; set max contour level
    res@txFont   = "helvetica-bold"
        res@gsnLeftString = "(b) TSR ERA5"
    res@gsnRightString = reg_mean(1) + " ~F22~W/m~S~2~"
    plot(1) = gsn_csm_contour_map_polar(wks,tsr_era,res)

    res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF       = -6                 ; set min contour level
    res@cnMaxLevelValF       = 6   
    ; res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    ; res@cnLevels := (/-4,-3,-2,-1,0,1,2,3,4/)
    res@txFont   = "helvetica-bold"
    res@gsnLeftString = "(c) MBE (a-b)"
    res@gsnRightString = reg_mean(2) + " ~F22~W/m~S~2~"
    plot(2) = gsn_csm_contour_map_polar(wks,mbe_toa,res)

      res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/0,1,2,3,4,5,6,7,8/)
    res@txFont   = "helvetica-bold"
    res@gsnLeftString = "(d) RMSE"
    res@gsnRightString = reg_mean(3) + " ~F22~W/m~S~2~"
    plot(3) = gsn_csm_contour_map_polar(wks,rmse_toa,res)
    resP = True
    resP@gsnMaximize        = True                   ; use full page

    gsn_panel(wks,plot,(/2,2/),resP)             ; now draw as one plot

end