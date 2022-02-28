begin

    data_path = "../Figure4/"
    data = addfile(str_concat((/data_path,"Figure4.nc"/)), "r") 
    lat = data->latitude
    print(lat)
    lon = data->longitude
    a = data->a

    tsr_a = data->tsr_a
    tsr_a_nn = data->tsr_a_nn
    tsr_sl = data->tsr_sl
    tsr_ref = data->tsr_ref
    tsr_ref_nn = data->tsr_ref_nn
    tsr_ref_sl = data->tsr_ref_sl
    dr_ker_toa = data->dR_ker_toa
    ssr_a = data->ssr_a
    ssr_a_nn = data->ssr_a_nn
    ssr_sl = data->ssr_sl
    ssr_ref = data->ssr_ref
    ssr_ref_nn = data->ssr_ref_nn
    ssr_ref_sl = data->ssr_ref_sl
    dr_ker_sfc = data->dR_ker_sfc

    tsr_a!0="a"
    tsr_a!1="lat"
    tsr_a!2="lon"
    tsr_a&a=a
    tsr_a&lon=lon
    tsr_a&lat=lat
    tsr_a&lon@units="degrees_east"
    tsr_a&lat@units="degrees_north"

    tsr_ref!0="lat"
    tsr_ref!1="lon"
    tsr_ref&lon=lon
    tsr_ref&lat=lat
    tsr_ref&lon@units="degrees_east"
    tsr_ref&lat@units="degrees_north"
    copy_VarCoords(tsr_a,tsr_a_nn)
    copy_VarCoords(tsr_a,tsr_sl)
    copy_VarCoords(tsr_a,dr_ker_toa)
    copy_VarCoords(tsr_ref,tsr_ref_sl)
    copy_VarCoords(tsr_ref,tsr_ref_nn)
    copy_VarCoords(tsr_a,ssr_a_nn)
    copy_VarCoords(tsr_a,ssr_sl)
    copy_VarCoords(tsr_a,dr_ker_sfc)
    copy_VarCoords(tsr_ref,ssr_ref_sl)
    copy_VarCoords(tsr_ref,ssr_ref_nn)

    dr_toa = tsr_a
    dr_nn_toa = tsr_a_nn
    dr_sl_toa = tsr_sl
    dr_sfc = tsr_a
    dr_nn_sfc = tsr_a_nn
    dr_sl_sfc = tsr_sl
    i = 0
    do while(i .le. 10)
        dr_toa(i,:,:) = tsr_a(i,:,:) - tsr_ref
        dr_nn_toa(i,:,:) = tsr_a_nn(i,:,:) - tsr_ref_nn
        dr_sl_toa(i,:,:) = tsr_sl(i,:,:) - tsr_ref_sl
        dr_sfc(i,:,:) = ssr_a(i,:,:) - ssr_ref
        dr_nn_sfc(i,:,:) = ssr_a_nn(i,:,:) - ssr_ref_nn
        dr_sl_sfc(i,:,:) = ssr_sl(i,:,:) - ssr_ref_sl
        i = i+1
    end do

    dif_nn_toa = dr_nn_toa - dr_toa
    dif_sl_toa = dr_sl_toa - dr_toa
    dif_ker_toa = dr_ker_toa - dr_toa
    copy_VarCoords(tsr_a,dif_nn_toa)
    copy_VarCoords(tsr_a,dif_sl_toa)
    copy_VarCoords(tsr_a,dif_ker_toa)
    dif_nn_sfc = dr_nn_sfc - dr_sfc
    dif_sl_sfc = dr_sl_sfc - dr_sfc
    dif_ker_sfc = dr_ker_sfc - dr_sfc
    copy_VarCoords(tsr_a,dif_nn_sfc)
    copy_VarCoords(tsr_a,dif_sl_sfc)
    copy_VarCoords(tsr_a,dif_ker_sfc)
    print(getvardimnames(dr_nn_toa) + " : " + dimsizes(dr_nn_toa))

    ia = 1;
     ; ; calculate global mean
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
    reg_mean(0) = wgt_areaave(dif_nn_toa(ia,:,:),area,1.0,opt_wgt)
    reg_mean(1) = wgt_areaave(dif_sl_toa(ia,:,:),area,1.0,opt_wgt)
    reg_mean(2) = wgt_areaave(dif_ker_toa(ia,:,:),area,1.0,opt_wgt)
    reg_mean(3) = wgt_areaave(dif_nn_sfc(ia,:,:),area,1.0,opt_wgt)
    reg_mean(4) = wgt_areaave(dif_sl_sfc(ia,:,:),area,1.0,opt_wgt)
    reg_mean(5) = wgt_areaave(dif_ker_sfc(ia,:,:),area,1.0,opt_wgt)
    reg_mean = decimalPlaces(reg_mean,2,True)    


    wks = gsn_open_wks("pdf","FigureS2")             ; send graphics to PNG file
    plot = new(6,graphic)

    res            = True                         ; plot mods desired
    res@gsnPolar   = "NH"                         ; specify the hemisphere
    res@mpMinLatF  = 70                       ; minimum lat to plot
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

    mj = 0.001
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

    res@lbLabelBarOn        = False           ; turn off individual cb's
    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-40,-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40/)
    res@txFont   = "helvetica-bold"
    res@gsnStringFontHeightF = 0.04
    res@gsnRightString = reg_mean(0)
    gsn_define_colormap(wks, "BlueDarkRed18")

    res@gsnLeftString = "(a) TOA ~F8~D~F22~R~B2~NN    - ~F8~D~F22~R"
    plot(0) = gsn_csm_contour_map_polar(wks,dif_nn_toa(ia,:,:),res)

    res@gsnLeftString = "(b) TOA ~F8~D~F22~R~B2~SL    - ~F8~D~F22~R"
    res@gsnRightString = reg_mean(1)
    plot(1) = gsn_csm_contour_map_polar(wks,dif_sl_toa(ia,:,:),res)

    res@gsnLeftString = "(c) TOA ~F8~D~F22~R~B3~Ker    - ~F8~D~F22~R"
    res@gsnRightString = reg_mean(2)
    plot(2) = gsn_csm_contour_map_polar(wks,dif_ker_toa(ia,:,:),res)

    res@gsnLeftString = "(d) SFC ~F8~D~F22~R~B2~NN    - ~F8~D~F22~R"
    res@gsnRightString = reg_mean(3)
    plot(3) = gsn_csm_contour_map_polar(wks,dif_nn_sfc(ia,:,:),res)

    res@gsnLeftString = "(e) SFC ~F8~D~F22~R~B2~SL    - ~F8~D~F22~R"
    res@gsnRightString = reg_mean(4)
    plot(4) = gsn_csm_contour_map_polar(wks,dif_sl_sfc(ia,:,:),res)

    res@gsnLeftString = "(f) SFC ~F8~D~F22~R~B3~Ker    - ~F8~D~F22~R"
    res@gsnRightString = reg_mean(5)
    plot(5) = gsn_csm_contour_map_polar(wks,dif_ker_sfc(ia,:,:),res)


    resP = True
    resP@gsnMaximize        = True                   ; use full page
    res@txFont   = "helvetica-bold"
  resP@gsnPanelLabelBar    = True                ; add common colorbar
    ; resP@gsnPanelMainString = "TOA"     ; set main title

    gsn_panel(wks,plot,(/2,3/),resP)             ; now draw as one plot

end