begin
data_path = "./" 
data = addfile(str_concat((/data_path,"ker_feedbacks_092012_091992.nc"/)), "r")
dr_a_sfc = data->Ra(:,:,1)
dr_w_sfc = data->Rwv(:,:,1)
dr_c_sfc = data->Rc(:,:,1)
dr_sfc = data->Rall(:,:,1)
lon = data->longitude
lat = data->latitude

dr_a_sfc!0="lat"
dr_a_sfc!1="lon"
dr_a_sfc&lon=lon
dr_a_sfc&lat=lat
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
dif_all = dr_sfc - sum_toa
copy_VarCoords(dr_a_sfc,dif_all)

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
reg_mean(0) = wgt_areaave(dr_sfc,area,1.0,opt_wgt)
reg_mean(1) = wgt_areaave(sum_toa,area,1.0,opt_wgt)
reg_mean(2) = wgt_areaave(dif_all,area,1.0,opt_wgt)
reg_mean(3) = wgt_areaave(dr_a_sfc,area,1.0,opt_wgt)
reg_mean(4) = wgt_areaave(dr_w_sfc,area,1.0,opt_wgt)
reg_mean(5) = wgt_areaave(dr_c_sfc,area,1.0,opt_wgt)
reg_mean = decimalPlaces(reg_mean,2,True)

wks = gsn_open_wks("pdf","FigureS9") 
plot = new(6,graphic)

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

gsn_define_colormap(wks, "BlueDarkRed18")
res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
res@cnLevels := (/-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20/)
res@txFont   = "helvetica-bold"
res@gsnStringFontHeightF = 0.06
res@gsnLeftString = "(a) ~F8~D~F22~R~S3~RTM~"
res@gsnRightString := sprintf("%.2f",reg_mean(0)) 
plot(0) = gsn_csm_contour_map_polar(wks,dr_sfc,res)

res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
res@cnLevels := (/-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20/)
res@gsnLeftString = "(b) ~F8~S~F8~D~F22~R~B1~X~S3~Ker~"
res@gsnRightString := sprintf("%.2f",reg_mean(1)) 
plot(1) = gsn_csm_contour_map_polar(wks,sum_toa,res)

res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
res@cnLevels := (/-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6/)
res@gsnLeftString = "(c) res"
res@gsnRightString := sprintf("%.2f",reg_mean(2)) 
plot(2) = gsn_csm_contour_map_polar(wks,dif_all,res)

res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
res@cnLevels := (/-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20/)
res@gsnLeftString = "(d) ~F8~D~F22~R~B1~a~S3~Ker~ "
res@gsnRightString := sprintf("%.2f",reg_mean(3))  
plot(3) = gsn_csm_contour_map_polar(wks,dr_a_sfc,res)

res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
res@cnLevels := (/-2.1,-1.8,-1.5,-1.2,-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1,1.2,1.5,1.8,2.1/)
res@gsnLeftString = "(e) ~F8~D~F22~R~B2~wv~S3~Ker~ "
res@gsnRightString := sprintf("%.2f",reg_mean(4)) 
plot(4) = gsn_csm_contour_map_polar(wks,dr_w_sfc,res)

res@cnLevelSelectionMode = "ExplicitLevels" ; manual levels
res@cnLevels := (/-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20/)
res@gsnLeftString = "(f) ~F8~D~F22~R~B1~c~S3~Ker~ "
res@gsnRightString := sprintf("%.2f",reg_mean(5)) 
plot(5) = gsn_csm_contour_map_polar(wks,dr_c_sfc,res)

resP = True
resP@gsnMaximize        = True                   ; use full page

gsn_panel(wks,plot,(/2,3/),resP)             ; now draw as one plot

end