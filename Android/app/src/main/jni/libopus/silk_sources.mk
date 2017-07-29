SILK_SOURCES = \
libopus/silk/CNG.c \
libopus/silk/code_signs.c \
libopus/silk/init_decoder.c \
libopus/silk/decode_core.c \
libopus/silk/decode_frame.c \
libopus/silk/decode_parameters.c \
libopus/silk/decode_indices.c \
libopus/silk/decode_pulses.c \
libopus/silk/decoder_set_fs.c \
libopus/silk/dec_API.c \
libopus/silk/enc_API.c \
libopus/silk/encode_indices.c \
libopus/silk/encode_pulses.c \
libopus/silk/gain_quant.c \
libopus/silk/interpolate.c \
libopus/silk/LP_variable_cutoff.c \
libopus/silk/NLSF_decode.c \
libopus/silk/NSQ.c \
libopus/silk/NSQ_del_dec.c \
libopus/silk/PLC.c \
libopus/silk/shell_coder.c \
libopus/silk/tables_gain.c \
libopus/silk/tables_LTP.c \
libopus/silk/tables_NLSF_CB_NB_MB.c \
libopus/silk/tables_NLSF_CB_WB.c \
libopus/silk/tables_other.c \
libopus/silk/tables_pitch_lag.c \
libopus/silk/tables_pulses_per_block.c \
libopus/silk/VAD.c \
libopus/silk/control_audio_bandwidth.c \
libopus/silk/quant_LTP_gains.c \
libopus/silk/VQ_WMat_EC.c \
libopus/silk/HP_variable_cutoff.c \
libopus/silk/NLSF_encode.c \
libopus/silk/NLSF_VQ.c \
libopus/silk/NLSF_unpack.c \
libopus/silk/NLSF_del_dec_quant.c \
libopus/silk/process_NLSFs.c \
libopus/silk/stereo_LR_to_MS.c \
libopus/silk/stereo_MS_to_LR.c \
libopus/silk/check_control_input.c \
libopus/silk/control_SNR.c \
libopus/silk/init_encoder.c \
libopus/silk/control_codec.c \
libopus/silk/A2NLSF.c \
libopus/silk/ana_filt_bank_1.c \
libopus/silk/biquad_alt.c \
libopus/silk/bwexpander_32.c \
libopus/silk/bwexpander.c \
libopus/silk/debug.c \
libopus/silk/decode_pitch.c \
libopus/silk/inner_prod_aligned.c \
libopus/silk/lin2log.c \
libopus/silk/log2lin.c \
libopus/silk/LPC_analysis_filter.c \
libopus/silk/LPC_inv_pred_gain.c \
libopus/silk/table_LSF_cos.c \
libopus/silk/NLSF2A.c \
libopus/silk/NLSF_stabilize.c \
libopus/silk/NLSF_VQ_weights_laroia.c \
libopus/silk/pitch_est_tables.c \
libopus/silk/resampler.c \
libopus/silk/resampler_down2_3.c \
libopus/silk/resampler_down2.c \
libopus/silk/resampler_private_AR2.c \
libopus/silk/resampler_private_down_FIR.c \
libopus/silk/resampler_private_IIR_FIR.c \
libopus/silk/resampler_private_up2_HQ.c \
libopus/silk/resampler_rom.c \
libopus/silk/sigm_Q15.c \
libopus/silk/sort.c \
libopus/silk/sum_sqr_shift.c \
libopus/silk/stereo_decode_pred.c \
libopus/silk/stereo_encode_pred.c \
libopus/silk/stereo_find_predictor.c \
libopus/silk/stereo_quant_pred.c \
libopus/silk/LPC_fit.c

SILK_SOURCES_SSE4_1 = libopus/silk/x86/NSQ_sse.c \
libopus/silk/x86/NSQ_del_dec_sse.c \
libopus/silk/x86/x86_silk_map.c \
libopus/silk/x86/VAD_sse.c \
libopus/silk/x86/VQ_WMat_EC_sse.c

SILK_SOURCES_ARM_NEON_INTR = \
libopus/silk/arm/arm_silk_map.c \
libopus/silk/arm/biquad_alt_neon_intr.c \
libopus/silk/arm/LPC_inv_pred_gain_neon_intr.c \
libopus/silk/arm/NSQ_del_dec_neon_intr.c \
libopus/silk/arm/NSQ_neon.c

SILK_SOURCES_FIXED = \
libopus/silk/fixed/LTP_analysis_filter_FIX.c \
libopus/silk/fixed/LTP_scale_ctrl_FIX.c \
libopus/silk/fixed/corrMatrix_FIX.c \
libopus/silk/fixed/encode_frame_FIX.c \
libopus/silk/fixed/find_LPC_FIX.c \
libopus/silk/fixed/find_LTP_FIX.c \
libopus/silk/fixed/find_pitch_lags_FIX.c \
libopus/silk/fixed/find_pred_coefs_FIX.c \
libopus/silk/fixed/noise_shape_analysis_FIX.c \
libopus/silk/fixed/process_gains_FIX.c \
libopus/silk/fixed/regularize_correlations_FIX.c \
libopus/silk/fixed/residual_energy16_FIX.c \
libopus/silk/fixed/residual_energy_FIX.c \
libopus/silk/fixed/warped_autocorrelation_FIX.c \
libopus/silk/fixed/apply_sine_window_FIX.c \
libopus/silk/fixed/autocorr_FIX.c \
libopus/silk/fixed/burg_modified_FIX.c \
libopus/silk/fixed/k2a_FIX.c \
libopus/silk/fixed/k2a_Q16_FIX.c \
libopus/silk/fixed/pitch_analysis_core_FIX.c \
libopus/silk/fixed/vector_ops_FIX.c \
libopus/silk/fixed/schur64_FIX.c \
libopus/silk/fixed/schur_FIX.c

SILK_SOURCES_FIXED_SSE4_1 = libopus/silk/fixed/x86/vector_ops_FIX_sse.c \
libopus/silk/fixed/x86/burg_modified_FIX_sse.c

SILK_SOURCES_FIXED_ARM_NEON_INTR = \
libopus/silk/fixed/arm/warped_autocorrelation_FIX_neon_intr.c

SILK_SOURCES_FLOAT = \
libopus/silk/float/apply_sine_window_FLP.c \
libopus/silk/float/corrMatrix_FLP.c \
libopus/silk/float/encode_frame_FLP.c \
libopus/silk/float/find_LPC_FLP.c \
libopus/silk/float/find_LTP_FLP.c \
libopus/silk/float/find_pitch_lags_FLP.c \
libopus/silk/float/find_pred_coefs_FLP.c \
libopus/silk/float/LPC_analysis_filter_FLP.c \
libopus/silk/float/LTP_analysis_filter_FLP.c \
libopus/silk/float/LTP_scale_ctrl_FLP.c \
libopus/silk/float/noise_shape_analysis_FLP.c \
libopus/silk/float/process_gains_FLP.c \
libopus/silk/float/regularize_correlations_FLP.c \
libopus/silk/float/residual_energy_FLP.c \
libopus/silk/float/warped_autocorrelation_FLP.c \
libopus/silk/float/wrappers_FLP.c \
libopus/silk/float/autocorrelation_FLP.c \
libopus/silk/float/burg_modified_FLP.c \
libopus/silk/float/bwexpander_FLP.c \
libopus/silk/float/energy_FLP.c \
libopus/silk/float/inner_product_FLP.c \
libopus/silk/float/k2a_FLP.c \
libopus/silk/float/LPC_inv_pred_gain_FLP.c \
libopus/silk/float/pitch_analysis_core_FLP.c \
libopus/silk/float/scale_copy_vector_FLP.c \
libopus/silk/float/scale_vector_FLP.c \
libopus/silk/float/schur_FLP.c \
libopus/silk/float/sort_FLP.c
