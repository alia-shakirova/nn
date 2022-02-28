begin

    data_path = "./"
    maxlat = 20
    data_nn  = addfile(str_concat((/data_path,"nn_sfc_feedbacks_091992_092012.nc"/)), "r") 
    lat = data_nn->latitude(0:maxlat)
    lon = data_nn->longitude

    dRa = data_nn->Ra(0:maxlat,:)
    dRc = data_nn->Rc(0:maxlat,:)
    dRwv = data_nn->Rwv(0:maxlat,:)
    dR = data_nn->dR(0:maxlat,:)

    dRa!0="lat"
    dRa!1="lon"
    dRa&lon=lon
    dRa&lat=lat
    dRa&lon@units="degrees_east"
    dRa&lat@units="degrees_north"
    copy_VarCoords(dRa,dRc)
    copy_VarCoords(dRa,dRwv)
    copy_VarCoords(dRa,dR)

    sum_univ = dRa + dRwv + dRc
    dif_all = dR - sum_univ 
    copy_VarCoords(dRa,sum_univ)
    copy_VarCoords(dRa,dif_all)

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
    reg_mean(0) = wgt_areaave(dR,area,1.0,opt_wgt)
    reg_mean(1) = wgt_areaave(sum_univ,area,1.0,opt_wgt)
    reg_mean(2) = wgt_areaave(dif_all,area,1.0,opt_wgt)
    reg_mean(3) = wgt_areaave(dRa,area,1.0,opt_wgt)
    reg_mean(4) = wgt_areaave(dRwv,area,1.0,opt_wgt)
    reg_mean(5) = wgt_areaave(dRc,area,1.0,opt_wgt)
    reg_mean = decimalPlaces(reg_mean,2,True)    

    wks = gsn_open_wks("pdf","FigureS81")             ; send graphics to PNG file
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

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20/)
    res@txFont   = "helvetica-bold"
    res@gsnStringFontHeightF = 0.06
        res@gsnLeftString = "(a) ~F8~D~F22~R"
    res@gsnRightString := sprintf("%.2f",reg_mean(0)) 
    gsn_define_colormap(wks, "BlueDarkRed18")
    plot(0) = gsn_csm_contour_map_polar(wks,dR,res)

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20/)
    res@gsnLeftString = "(b) ~F8~S~F8~D~F22~R~B~univ~NN~"
    res@gsnRightString := sprintf("%.2f",reg_mean(1)) 
    plot(1) = gsn_csm_contour_map_polar(wks,sum_univ,res)

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6/)
    res@gsnLeftString = "(c) res"
    res@gsnRightString := sprintf("%.2f",reg_mean(2)) 
    plot(2) = gsn_csm_contour_map_polar(wks,dif_all,res)

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20/)
    res@gsnLeftString = "(d) ~F8~D~F22~R~B~a~NN~"
    res@gsnRightString := sprintf("%.2f",reg_mean(3)) 
    plot(3) = gsn_csm_contour_map_polar(wks,dRa,res)

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-2.1,-1.8,-1.5,-1.2,-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1,1.2,1.5,1.8,2.1/)
    ; res@cnLevels := (/-1.5,-1.2,-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1,1.2,1.5/)
    res@gsnLeftString = "(e) ~F8~D~F22~R~B~wv~NN~"
    res@gsnRightString := sprintf("%.2f",reg_mean(4)) 
    plot(4) = gsn_csm_contour_map_polar(wks,dRwv,res)

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20/)
    res@gsnLeftString = "(f) ~F8~D~F22~R~B~c~NN~"
    res@gsnRightString := sprintf("%.2f",reg_mean(5)) 
    plot(5) = gsn_csm_contour_map_polar(wks,dRc,res)
    
    resP = True
    resP@gsnMaximize        = True                   ; use full page
    gsn_panel(wks,plot,(/2,3/),resP)             ; now draw as one plot

end