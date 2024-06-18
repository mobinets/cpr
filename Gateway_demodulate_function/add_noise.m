function (output) = add_noise(input, SNR, length)
    amp_input = mean(abs(input));
    amp_noise = amp_input/10^(SNR/20);
    if length(input) ~= length
        input_adzero = [input, zeros(1, length - length(input))];
    end
    output  = input_adzero + (amp_noise/sqrt(2) * randn([1 length]) + 1i*amp_noise/sqrt(2) * randn([1 length]));
