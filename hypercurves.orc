; To learn about Hypercurve, see github.com/johannphilippe/hypercurve

gidef = 1024
giascend_bip = hc_hypercurve(0, gidef, 0, hc_segment(1, 1, hc_diocles_curve(0.51)))
hc_scale(giascend_bip, -1, 1)
gidescend = hc_hypercurve(0, gidef, 1,
        hc_segment(1, 0, hc_diocles_curve(0.51)))

gifastatq = hc_hypercurve(0, gidef, 0,
                hc_segment(1/128, 1, hc_tightrope_walker_curve(1.1, 0.1)),
                hc_segment(127/128, 0, hc_diocles_curve(0.51)))

gihcslow = hc_hypercurve(0, gidef, 0,  
                hc_segment(1/3, 1, hc_catenary_curve(0.2)),
                hc_segment(2/3, 0, hc_gaussian_curve(2, 3)))

gistcrv = hc_hypercurve(0, gidef, 0,
                hc_segment(1/8, 1, hc_mirror(hc_power_curve(6))),
                hc_segment(7/8, 0, hc_mirror(hc_power_curve(3))))
hc_scale(gistcrv, 0, 1)

gisoft = hc_hypercurve(0, gidef, 0, 
				hc_segment(1/4, 1, hc_toxoid_curve(20)), 
				hc_segment(3/4, 0, hc_toxoid_curve(10)))

gihc_traj_cubic_concav = hc_hypercurve(0, 1000, 0,
			hc_segment(0.5, 1, hc_mirror(hc_cubic_curve())),
			hc_segment(0.5, 0, hc_mirror(hc_cubic_curve())))

gihc_traj_linear = hc_hypercurve(0, 1000, 0,
			hc_segment(0.5, 1, hc_mirror(hc_linear_curve())),
			hc_segment(0.5, 0, hc_mirror(hc_linear_curve())))

gihc_blackman = hc_hypercurve(0, 1000, 0,
			hc_segment(0.5, 1, hc_blackman_curve()),
			hc_segment(0.5, 0, hc_blackman_curve()))
hc_scale(gihc_blackman, 0, 1)
gihc_hamming = hc_hypercurve(0, 1000, 0,
			hc_segment(0.5, 1, hc_hamming_curve()),
			hc_segment(0.5, 0, hc_hamming_curve()))
hc_scale(gihc_hamming, 0, 1)
gihc_hanning = hc_hypercurve(0, 1000, 0,
			hc_segment(0.5, 1, hc_hanning_curve()),
			hc_segment(0.5, 0, hc_hanning_curve()))

gihc_cubic_bezier = hc_hypercurve(0, gidef, 0, 
			hc_segment(0.1, 1, 
				hc_cubic_bezier_curve( hc_control_point(0.3, 0), hc_control_point(0.7, 0.9)  )),
			hc_segment(0.9, 0,
				hc_cubic_bezier_curve( hc_control_point(0.2, 0.2), hc_control_point(0.4, 0.99) )))

gidiocles = hc_hypercurve(0, gidef, 0, 
			hc_segment(0.5, 1, hc_diocles_curve(0.51)), 
			hc_segment(0.5, 0, hc_diocles_curve(0.51)))

gitight = hc_hypercurve(0, gidef, 0,
			hc_segment(0.01, 1, hc_tightrope_walker_curve(1.1, 0.1)),
			hc_segment(0.99, 0, hc_cubic_bezier_curve( hc_control_point(0.2, 0.01), hc_control_point(0.8, 0.6)   )))

gifade = hc_hypercurve(0, gidef, 0, 
			hc_segment(0.01, 1, hc_linear_curve()),
			hc_segment(0.98, 1, hc_linear_curve()),
			hc_segment(0.01, 0, hc_linear_curve()))
			
gitriangle = hc_hypercurve(0, gidef, 0,
				hc_segment(0.5, 1, hc_linear_curve()), 
				hc_segment(0.5, 0, hc_linear_curve()))
