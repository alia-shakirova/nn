begin

    data_path = "../../era5_grid1_data/"
    data_sie = addfile(str_concat((/data_path,"CI_era5.nc"/)), "r")
    data_tcc = addfile(str_concat((/data_path,"TCC_era5.nc"/)), "r")
    data_a = addfile(str_concat((/data_path,"FAL_era5.nc"/)), "r")
    data_tcwv = addfile(str_concat((/data_path,"TCWV_era5.nc"/)), "r")
    data_tsr = addfile(str_concat((/data_path,"TSR_era5.nc"/)), "r")
    data_ssr = addfile(str_concat((/data_path,"SSR_era5.nc"/)), "r")

    maxlat = 20
    lat = data_sie->latitude(0:maxlat)
    lon = data_sie->longitude

    ci = short2flt( data_sie->siconc(:,0:maxlat,:) )
    time =data_sie->time    
    tcc = short2flt( data_tcc->tcc(:,0:maxlat,:) )
    a = short2flt( data_a->fal(:,0:maxlat,:) )
    tcwv = short2flt( data_tcwv->tcwv(:,0:maxlat,:) )
    tsr = short2flt( data_tsr->tsr(:,0:maxlat,:) )
    tsr = tsr/24/3600
    ssr = short2flt( data_ssr->ssr(:,0:maxlat,:) )
    ssr = ssr/24/3600
    sie = ci
    sie = where(ci .ge. 0.15,ci,0)

    st = 0 ; Sept 1992
    en = 1 ; Sept 2012
    dsie = sie(st,:,:)-sie(en,:,:)
    dtcc = tcc(st,:,:)-tcc(en,:,:)
    da = a(st,:,:)-a(en,:,:)
    dtcwv = tcwv(st,:,:)-tcwv(en,:,:)
    dssr = ssr(st,:,:)-ssr(en,:,:)
    dtsr = tsr(st,:,:)-tsr(en,:,:)

    copy_VarCoords(sie(1,:,:),dsie)
    copy_VarCoords(sie(1,:,:),dtcc)
    copy_VarCoords(sie(1,:,:),da)
    copy_VarCoords(sie(1,:,:),dtcwv)
    copy_VarCoords(sie(1,:,:),dtsr)
    copy_VarCoords(sie(1,:,:),dssr)
    
    ; calculate global mean
    re             = 6.37122e06           ; earth radius [m]
    rad            = 4.0*atan(1.0)/180.0          ; get radiance
    clat           = cos(lat*rad)         ; cosine of latitude

    dlon           = (lon(2) - lon(1))    ; assume dlon is constant
    dlat           = (lat(2) - lat(1))    ; assume dlat is constant

    dx             = dlon*clat            ; dx at each latitude
    dy             = dlat*re*rad          ; dy is costant
    area           = dy*dx                ; area(nlat)
    opt_wgt        = 0    ;0-calculate non-missing data

    reg_mean = new(6,float)
    reg_mean(0) = wgt_areaave(dsie,area,1.0,opt_wgt)
    reg_mean(1) = wgt_areaave(da,area,1.0,opt_wgt)
    reg_mean(2) = wgt_areaave(dtcc,area,1.0,opt_wgt)
    reg_mean(3) = wgt_areaave(dtcwv,area,1.0,opt_wgt)
    reg_mean(4) = wgt_areaave(dtsr,area,1.0,opt_wgt)
    reg_mean(5) = wgt_areaave(dssr,area,1.0,opt_wgt)
    reg_mean = decimalPlaces(reg_mean,2,True)

    wks = gsn_open_wks("pdf","Figure6")             ; send graphics to PNG file
    plot = new(6,graphic)

    res            = True                         ; plot mods desired
    res@gsnPolar   = "NH"                         ; specify the hemisphere
    res@mpMinLatF  = 70                          ; minimum lat to plot
    ; res@cnFillPalette        = colors
    res@cnFillOn             = True               ; turns on the color
    res@mpFillOn             = False              ; turns off continent gray
    res@cnLinesOn            = False              ; turn off contour lines

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

    mj = 0.01
    mi = 0.005
    res@tmXBMajorLengthF = mj
    res@tmXBMajorOutwardLengthF = -0.0
    res@tmXBMinorLengthF = mi
    res@tmXBMinorOutwardLengthF = -0.0
    res@tmXTMajorLengthF = mj
    res@tmXTMajorOutwardLengthF = -0.0
    res@tmXTMinorLengthF = mi
    res@tmXTMinorOutwardLengthF = -0.0
    res@tmYLMajorLengthF = mj
    res@tmYLMajorOutwardLengthF = -0.0
    res@tmYLMinorLengthF = mi
    res@tmYLMinorOutwardLengthF = -0.0
    res@tmYRMajorLengthF = mj
    res@tmYRMajorOutwardLengthF = -0.0
    res@tmYRMinorLengthF = mi
    res@tmYRMinorOutwardLengthF = -0.

    res@gsnStringFontHeightF = 0.045
    res@lbLabelFontHeightF = 0.045

    res@mpShapeMode  = "FreeAspect"
    res@vpHeightF = 1.0
    res@vpWidthF = 1.0

    res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF       := -0.9                 ; set min contour level
    res@cnMaxLevelValF       := 0.9               ; set max contour level
    res@txFont   = "helvetica-bold"
    res@gsnLeftString = "~F22~(a) ~F8~D~F22~sie"
    gsn_define_colormap(wks, "BlueDarkRed18")
    res@gsnRightString := sprintf("%.2f",reg_mean(0))
    plot(0) = gsn_csm_contour_map_polar(wks,dsie,res)

    res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF       = -0.9                 ; set min contour level
    res@cnMaxLevelValF       = 0.9                ; set max contour level
    res@gsnLeftString = "~F22~(b) ~F8~D~F22~a"
    res@gsnRightString := sprintf("%.2f",reg_mean(1))
    plot(1) = gsn_csm_contour_map_polar(wks,da,res)

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-0.15,-0.12,-0.09,-0.06,-0.03,-0.01,0,0.01,0.03,0.06,0.09,0.12,0.15/)
    res@gsnLeftString = "~F22~(c) ~F8~D~F22~tcc"
    res@gsnRightString := sprintf("%.2f",reg_mean(2))
    plot(2) = gsn_csm_contour_map_polar(wks,dtcc,res)


    res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF      := -6                 ; set min contour level
    res@cnMaxLevelValF       := 6                ; set max contour level
    res@gsnLeftString = "~F22~(d) ~F8~D~F22~tcwv"
    res@gsnRightString := sprintf("%.2f",reg_mean(3)) + " ~F22~kg/m~S~2~";+ " %" ;
    plot(3) = gsn_csm_contour_map_polar(wks,dtcwv,res)

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20/)
    res@gsnLeftString = "~F22~(e) ~F8~D~F22~R at the TOA"
    res@gsnRightString := sprintf("%.2f",reg_mean(4)) + " ~F22~W/m~S~2~"
    plot(4) = gsn_csm_contour_map_polar(wks,dtsr,res)

    res@gsnLeftString = "~F22~(f) ~F8~D~F22~R at the surface"
    res@gsnRightString := sprintf("%.2f",reg_mean(5))  + " ~F22~W/m~S~2~"
    plot(5) = gsn_csm_contour_map_polar(wks,dssr,res)

    resP = True
    resP@gsnMaximize        = True                   ; use full page
    ; resP@gsnPanelMainString = "Sept. 1992 - Sept. 2012"     ; set main title

    gsn_panel(wks,plot,(/2,3/),resP)             ; now draw as one plot


end