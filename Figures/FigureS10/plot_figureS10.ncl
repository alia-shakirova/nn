begin

    data_path = "../Figure7/"
    data = addfile(str_concat((/data_path,"rtm_feedbacks_092012_091992.nc"/)), "r")
    maxlat = 20;
    lat = data->latitude(0:maxlat)
    lon = data->longitude

    dRa_sfc = data->dRa_sfc(0:maxlat,:)
    dRc_sfc = data->dRc_sfc(0:maxlat,:)
    dRwv_sfc = data->dRwv_sfc(0:maxlat,:)
    dR_sfc = data->dR_sfc(0:maxlat,:)
    dR_sfc!0="lat"
    dR_sfc!1="lon"
    dR_sfc&lon=lon
    dR_sfc&lat=lat
    dR_sfc&lon@units="degrees_east"
    dR_sfc&lat@units="degrees_north"
    copy_VarCoords(dR_sfc,dRa_sfc)
    copy_VarCoords(dR_sfc,dRwv_sfc)
    copy_VarCoords(dR_sfc,dRc_sfc)
    sum_univ = dRa_sfc + dRwv_sfc + dRc_sfc
    dif_all = dR_sfc - sum_univ 
    copy_VarCoords(dR_sfc,sum_univ)
    copy_VarCoords(dR_sfc,dif_all)
    dRa_sfc = lonFlip(dRa_sfc)
    dRwv_sfc = lonFlip(dRwv_sfc)
    dRc_sfc = lonFlip(dRc_sfc)
    dR_sfc = lonFlip(dR_sfc)

    data_path = "../FigureS8/"
    maxlat = 20;
    data_nn  = addfile(str_concat((/data_path,"nn_sfc_feedbacks_091992_092012.nc"/)), "r")
    latnn = data_nn->latitude(0:maxlat)
    lonnn = data_nn->longitude

    dRa = data_nn->Ra(0:maxlat,:)
    dRc = data_nn->Rc(0:maxlat,:)
    dRwv = data_nn->Rwv(0:maxlat,:)
    dR = data_nn->dR(0:maxlat,:)

    dRa!0="lat"
    dRa!1="lon"
    dRa&lon=lonnn
    dRa&lat=latnn
    dRa&lon@units="degrees_east"
    dRa&lat@units="degrees_north"
    copy_VarCoords(dRa,dRc)
    copy_VarCoords(dRa,dRwv)
    copy_VarCoords(dRa,dR)
    sum_univ_nn = dRa + dRwv + dRc
    dif_all_nn = dR - sum_univ 
    copy_VarCoords(dRa,sum_univ_nn)
    copy_VarCoords(dRa,dif_all_nn)

    bias_dr = dR - dR_sfc
    bias_sum_univ = sum_univ_nn - sum_univ
    bias_dr_a = dRa - dRa_sfc
    bias_dr_c = dRc - dRc_sfc   
    bias_dr_w = dRwv - dRwv_sfc

    copy_VarCoords(dRa,bias_dr)
    copy_VarCoords(dRa,bias_sum_univ)
    copy_VarCoords(dRa,bias_dr_a)
    copy_VarCoords(dRa,bias_dr_w)
    copy_VarCoords(dRa,bias_dr_c)

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

    reg_mean = new(4,float)
    reg_mean(0) = wgt_areaave(bias_dr,area,1.0,opt_wgt)
    reg_mean(1) = wgt_areaave(bias_dr_a,area,1.0,opt_wgt)
    reg_mean(2) = wgt_areaave(bias_dr_w,area,1.0,opt_wgt)
    reg_mean(3) = wgt_areaave(bias_dr_c,area,1.0,opt_wgt)
    reg_mean = decimalPlaces(reg_mean,2,True)       

    data_path = "../Figure9/"
    data = addfile(str_concat((/data_path,"ker_feedbacks_092012_091992.nc"/)), "r") 
    dr_a_sfc = data->Ra(:,:,1)
    dr_w_sfc = data->Rwv(:,:,1)
    dr_c_sfc = data->Rc(:,:,1)
    dr_sfc = data->Rall(:,:,1)
    lonker = data->longitude
    latker = data->latitude

    dr_a_sfc!0="lat"
    dr_a_sfc!1="lon"
    dr_a_sfc&lon=lonker
    dr_a_sfc&lat=latker
    dr_a_sfc&lon@units="degrees_east"
    dr_a_sfc&lat@units="degrees_north"
    
    if (any(isnan_ieee(dr_w_sfc))) then
    if(.not.isatt(dr_w_sfc,"_FillValue")) then
      dr_w_sfc@_FillValue = default_fillvalue(typeof(dr_w_sfc))
    end if
    replace_ieeenan (dr_w_sfc, dr_w_sfc@_FillValue, 0)
    end if
    if (any(isnan_ieee(dr_c_sfc))) then
    if(.not.isatt(dr_c_sfc,"_FillValue")) then
      dr_c_sfc@_FillValue = default_fillvalue(typeof(dr_c_sfc))
    end if
    replace_ieeenan (dr_c_sfc, dr_c_sfc@_FillValue, 0)
    end if
    if (any(isnan_ieee(dr_a_sfc))) then
    if(.not.isatt(dr_a_sfc,"_FillValue")) then
      dr_a_sfc@_FillValue = default_fillvalue(typeof(dr_a_sfc))
    end if
    replace_ieeenan (dr_a_sfc, dr_a_sfc@_FillValue, 0)
    end if
    
    copy_VarCoords(dr_a_sfc,dr_w_sfc)
    copy_VarCoords(dr_a_sfc,dr_c_sfc)
    copy_VarCoords(dr_a_sfc,dr_sfc)
    sum_toa = dr_a_sfc + dr_c_sfc + dr_w_sfc
    copy_VarCoords(dr_a_sfc,sum_toa)

    bias_dr_ker = dR_sfc - dr_sfc
    bias_sumuniv_ker = sum_toa - sum_univ
    bias_dr_a_ker = dr_a_sfc - dRa_sfc  
    bias_dr_c_ker = dr_c_sfc - dRc_sfc   
    bias_dr_w_ker = dr_w_sfc - dRwv_sfc
    copy_VarCoords(dRa,bias_dr_ker)
    copy_VarCoords(dRa,bias_sumuniv_ker)
    copy_VarCoords(dRa,bias_dr_a_ker)
    copy_VarCoords(dRa,bias_dr_w_ker)
    copy_VarCoords(dRa,bias_dr_c_ker)

    reg_mean_ker = new(4,float)
    reg_mean_ker(0) = wgt_areaave(bias_dr_ker,area,1.0,opt_wgt)
    reg_mean_ker(1) = wgt_areaave(bias_dr_a_ker,area,1.0,opt_wgt)
    reg_mean_ker(2) = wgt_areaave(bias_dr_w_ker,area,1.0,opt_wgt)
    reg_mean_ker(3) = wgt_areaave(bias_dr_c_ker,area,1.0,opt_wgt)
    reg_mean_ker = decimalPlaces(reg_mean_ker,2,True)   
    print(wgt_areaave(bias_sumuniv_ker,area,1.0,opt_wgt))
    print(wgt_areaave(bias_sum_univ,area,1.0,opt_wgt))

    wks = gsn_open_wks("pdf","FigureS10")             ; send graphics to PNG file
    plot = new(9,graphic)

    res            = True                         ; plot mods desired
    res@gsnPolar   = "NH"                         ; specify the hemisphere
    res@mpMinLatF  = 70                         ; minimum lat to plot
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
    res@cnLevels := (/-10.5,-9,-7.5,-6,-4.5,-3,-1.5,0,1.5,3,4.5,6,7.5,9,10.5/)   
    ; res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    ; res@cnMinLevelValF       := -10                 ; set min contour level
    ; res@cnMaxLevelValF       := 10                ; set max contour level
    res@txFont   = "helvetica-bold"
    res@gsnStringFontHeightF = 0.06
    res@gsnLeftString = "(a) ~F8~D~F22~R~S2~NN   - ~F8~D~F22~R~S3~RTM"
    res@gsnRightString = reg_mean(0)
    gsn_define_colormap(wks, "BlueDarkRed18")
    plot(0) = gsn_csm_contour_map_polar(wks,bias_dr,res)

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-10.5,-9,-7.5,-6,-4.5,-3,-1.5,0,1.5,3,4.5,6,7.5,9,10.5/)
    ; res@cnLevels := (/-10,-7.5,-5,-2.5,0,2.5,5,7.5,10/)
    res@gsnLeftString = "(b) ~F8~D~F22~R~B1~a~S3~Ker   - ~F8~D~F22~R~B1~a~S3~RTM"
    res@gsnRightString = reg_mean_ker(1)
    plot(3) = gsn_csm_contour_map_polar(wks,bias_dr_a_ker,res)


    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-1.5,-1.2,-0.9,-0.6,-0.3,-0.1,0,0.1,0.3,0.6,0.9,1.2,1.5/)
    res@gsnLeftString = "(c) ~F8~D~F22~R~B1~w~S3~Ker   - ~F8~D~F22~R~B1~w~S3~RTM"
    res@gsnRightString = reg_mean_ker(2)
    plot(4) = gsn_csm_contour_map_polar(wks,bias_dr_w_ker,res)

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-9,-7.5,-6,-4.5,-3,-1.5,0,1.5,3,4.5,6,7.5,9/)
    ; res@cnLevels := (/-10,-7.5,-5,-2.5,0,2.5,5,7.5,10/)
    res@gsnLeftString = "(d) ~F8~D~F22~R~B1~c~S3~Ker   - ~F8~D~F22~R~B1~c~S3~RTM"
    res@gsnRightString = reg_mean_ker(3)
    plot(5) = gsn_csm_contour_map_polar(wks,bias_dr_c_ker,res)


    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    ; res@cnLevels := (/-10,-7.5,-5,-2.5,0,2.5,5,7.5,10/)
    res@cnLevels := (/-10.5,-9,-7.5,-6,-4.5,-3,-1.5,0,1.5,3,4.5,6,7.5,9,10.5/)
    res@gsnLeftString = "(e) ~F8~D~F22~R~B1~a~S2~NN   - ~F8~D~F22~R~B1~a~S3~RTM"
    res@gsnRightString = reg_mean(1)
    plot(6) = gsn_csm_contour_map_polar(wks,bias_dr_a,res)

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-1.5,-1.2,-0.9,-0.6,-0.3,-0.1,0,0.1,0.3,0.6,0.9,1.2,1.5/)
    res@gsnLeftString = "(f) ~F8~D~F22~R~B1~w~S2~NN   - ~F8~D~F22~R~B1~w~S3~RTM"
    res@gsnRightString =reg_mean(2)
    plot(7) = gsn_csm_contour_map_polar(wks,bias_dr_w,res)

    res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
    res@cnLevels := (/-9,-7.5,-6,-4.5,-3,-1.5,0,1.5,3,4.5,6,7.5,9/)
    res@gsnLeftString = "(g) ~F8~D~F22~R~B1~c~S2~NN   - ~F8~D~F22~R~B1~c~S3~RTM"
    res@gsnRightString = reg_mean(3)
    plot(8) = gsn_csm_contour_map_polar(wks,bias_dr_c,res)
    
    resP = True
    resP@gsnMaximize        = True                   ; use full page
    gsn_panel(wks,plot,(/4,3/),resP)             ; now draw as one plot


end