1. **`nelly_main.m`** 

   `[freq, n_fit, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref] = `**`nelly_main`**`(input, t_smp, A_smp, t_ref, A_ref)`

   **Input arguments**

    	1. **`input`** Contains the input specification, which includes **data processing parameters** like windowing and zero-padding, and the **geometry specification**, which gives the thickness and refractive index for each layer. This variable can either be a structure string pointing to a JSON file,
    	2. **`t_smp`** and  **`A_smp`** are vectors containing the time-domain trace for the sample geometry; **`t_ref`** and  **`A_ref`** give the time-domain trace for the reference geometry 

   **Output arguments**

   1. **`freq`** is a vector containing the frequency points for the results
   2. **`n_fit`** is a vector containing the refractive indices extracted. The corresponding frequency points can be found in **`freq`**
   3. **`freq_full`** is the full range of frequency points created by the zero-padded Fourier transform
   4. **`tf_full`** is a vector containing  the transfer function--i.e. E_sample/E_ref--at each frequency point in **`freq_full`** 
   5. **`tf_spec` ** is a vector containing  the transfer function-at each frequency point in **`freq`** 
   6. **`tf_pred`** is the transfer function predicted with the extracted refractive index (values correspond to **`freq`**)
   7. **`func`** is a handle to an anonymous function that takes two arguments--a frequency and a value for the unknown refractive index--and returns the value of the transfer function at that frequency. 
   8. **`spec_smp`** is the complex spectrum for the sample geometry. The points correspond to **`freq`** 
   9. **`spec_ref`** is the complex spectrum for the reference geometry. The points correspond to **`freq`** 

2. **`fft_func.m`**

   `[freq, spec] = `**`fft_func`**`(time, amplitude, options)`

   **Input arguments** 

   1. **`time`** and **`amplitude`**  are vectors giving the time domain trace to be Fourier transformed
   2. **`options`** is a structure which gives the padding used. The structure should match that found in the `fft` portion of the `settings` section of the example input files (i.e. it should have fields for `windowing_type` etc.) 

