
use_bpm 45

@main_progression = (ring chord(:A3, :major, num_octaves: 2), chord(:A3, :minor7, num_octaves: 2), chord(:F3, :major, num_octaves: 2), chord(:E3, :madd11, num_octaves: 2)) +
  (ring chord(:A3, :major, num_octaves: 2), chord(:A3, :minor7, num_octaves: 2), chord(:F3, :major, num_octaves: 2), chord(:G3, :major, num_octaves: 2))

@intro_progression = (ring  chord(:A3, :minor7, num_octaves: 2), chord(:E3, :madd11, num_octaves: 2)) +
  (ring  chord(:A3, :minor7, num_octaves: 2),  chord(:G3, :major, num_octaves: 2))

def linear_slide(from, to, duration)
  ((0...duration).to_a.map {|x| x * (to - from) / duration + from}).ring
end

def chance?(chances)
  dice(chances[1]) <= chances[0]
end

def cumsum(arr)
  sum = 0
  arr.map{|x| sum += x}
end

def diff_lag(arr)
  curr = 0
  arr.map do |x|
    diff = x - curr
    curr = x
    diff
  end
end

def polyrithm(parts_num_a, parts_num_b)
  times_a = cumsum([1.0/parts_num_a] * parts_num_a)
  times_b = cumsum([1.0/parts_num_b] * parts_num_b)
  all_times = (times_a + times_b).sort.uniq
  diff_lag(all_times)
end

def play_progression(progression, time, amp, skips=[], skip_chances=[1,1], is_note=false)
  achord = progression.tick
  time.each_with_index do |time, index|
    unless skips.include? index and chance? skip_chances
      obj = is_note ? achord.choose : achord
      gain = amp[index] - rand(0.02)
      print is_note
      if is_note
        gain = gain * 0.8
      end
      
      asynth = play obj, amp: gain,
        atack: rand(0.05), decay: 0.1, sustain_level: 0.8, sustain: 0.2 + rand(0.05),
        release: 0.3 + rand(0.05)
      yield asynth
    end
    sleep time
  end
end

@main_duration1 = 16
@main_duration2 = 40

@durations = polyrithm 4, 3
@bass_durations = polyrithm 8, 6

@amp_pattern = [1.0, 0.85, 1.0, 0.7, 0.9, 0.6]
@intro_duration = 24

def play_intro(is_note)
  with_fx :ixi_techno, mix: 0.2, phase: 64 do
    depths = linear_slide(0.5, 4, @intro_duration + 1)
    amps = linear_slide(0.5, 0.8, @intro_duration + 1)
    @intro_duration.times do
      depth = depths.look
      avg_amp = amps.look
      play_progression @intro_progression, @durations, @amp_pattern.map{|x| x * avg_amp}, skips=[4], skip_chances=[1, 4], is_note=is_note do |synth|
        control synth, depth: depth
      end
    end
  end
end

def play_main1(is_note)
  depths = linear_slide(3.0, 4.0, @main_duration1 + 1).reverse
  @main_duration1.times do
    depth = depths.look
    play_progression @main_progression, @durations, @amp_pattern, skips=[4], skip_chances=[1, 2], is_note=is_note do |synth|
      control synth, depth: depth
    end
  end
end

def play_main2(is_note)
  mixs = linear_slide(0, 0.7, @main_duration2 + 1)
  with_fx :lpf do
    with_fx :ring_mod, mix: 0 do |effect1|
      with_fx :panslicer, mix: 0, wave: 3 , phase: 4, pan_min: -0.7, pan_max: 0.7 do |effect2|
        with_fx :ixi_techno, mix: 0, phase: 4 do |effect3|
          @main_duration2.times do
            mix = mixs.look
            control effect1, mix: mix
            control effect2, mix: mix
            control effect3, mix: mix
            play_progression @main_progression, @durations, @amp_pattern, skips=[], skip_chances=[1, 1], is_note=is_note do |synth|
              control synth, depth: 3
            end
          end
        end
      end
    end
  end
end

in_thread do
  with_fx :reverb do
    use_synth :fm
    play_intro(false)
    play_main1(false)
    play_main2(false)
  end
end

def play_melody(progression, time, amp, pattern)
  achord = progression.tick()
  time.each_with_index do |time, index|
    asynth = play achord[pattern[index]] -12, amp: amp[index], division: 1, depth: 5, atack: 0, release: 0.2
    yield asynth
    sleep time
  end
end

def generate_melody()
  ((0...5).to_a * 4).shuffle.ring
end


in_thread do
  with_fx :tremolo do
    use_synth :fm
    notes = generate_melody()
    amps = linear_slide(0.0, 0.8, @intro_duration + 1)
    print amps
    @intro_duration.times do
      if one_in(8)
        notes = generate_melody()
      end
      play_melody @intro_progression, @durations, [0.9, amps.look].ring.mirror, notes do |synth|
      end
    end
    with_fx  :ixi_techno, phase: 16, cutoff_min: 70, cutoff_max: 85 do
      (@main_duration1 + @main_duration2 + 16).times do
        if one_in(8)
          notes = generate_melody()
        end
        durations = one_in(4) ? @durations : @bass_durations
        play_melody @main_progression, durations, [1, 0.7].ring.reflect, notes do |synth|
        end
      end
    end
  end
end

in_thread do
  @intro_duration.times do
    3.times do
      change = one_in(10)
      with_fx :krush, mix: 0.1 do
        sample :loop_weirdo, atack: 0, release: 0.1, finish: change ? 0.2 : 0.1, start: change ? 0.15 : 0.0, amp: change ? 0.8 : 1.0, rate: 0.75
      end
      sleep 1.0/3
    end
  end
end


in_thread do
  sleep 8
  (@intro_duration - 8).times do
    4.times do
      change = one_in(10)
      with_fx :tanh, mix: 0.1 do
        sample :loop_weirdo, atack: 0, release: 0.1, finish: change ? 0.2 : 0.1, start: change ? 0.15 : 0.0, amp: change ? 0.4 : 0.8, rate: 1
      end
      sleep 1.0/4
    end
  end
end


in_thread do
  with_fx :distortion, mix: 0.5 do
    sleep 16
    (@intro_duration + @main_duration1 + @main_duration2 -16).times do
      3.times do
        sample :bd_tek
        sleep 1.0/3
      end
    end
  end
end

in_thread do
  sleep 20
  with_fx :krush, mix: 0.5 do
    amps = linear_slide(0.5, 2.0, 4 * 20)
    rates = linear_slide(1.0, 15.0, 4 * 20)
    (3).times do
      @durations.each do |time|
        sample :perc_snap, amp: amps.tick, rate: rates.look
        sample :drum_tom_lo_hard, amp: amps.look, finish: 0.3, rate: rates.look
        sleep time
      end
    end
    @bass_durations.each do |time|
      sample :perc_snap, amp: amps.tick, rate: rates.look
      sample :drum_tom_lo_hard, amp: amps.look, finish: 0.3, rate: rates.look
      sleep time
    end
    sample :drum_cymbal_open
    sample :sn_dolf
  end
end

def glitchs(amp, avg_amp)
  sounds = [:glitch_perc2, :glitch_perc3].ring
  sample sounds.choose, finish: 0.3, release: 0.3, rate: 1.5 + rand(0.5), atack: 0.05, amp: 2 * avg_amp.look
  sample :tabla_ke1, finish: 0.15
  
  sleep 0.5
  sample sounds.choose,  finish: 0.3, release: 0.3, atack: 0.05, rate: 1.5 + rand(0.5), amp: amp.tick * avg_amp.look
  sample :tabla_ke1, finish: 0.15
  sleep 0.5
end


in_thread do
  with_fx :reverb do
    with_fx :ring_mod, mix: 0.3 do
      with_fx :echo, mix: 0.5, phase: 1.0 / 3, decay: 2.0 /3 do
        amp = [0, 1].ring
        sleep @intro_duration
        (24).times do
          glitchs(amp, [1].ring)
        end
        avg_amp = linear_slide(0.1, 1, 12).reverse
        (8).times do
          glitchs(amp, avg_amp)
        end
      end
    end
  end
end


in_thread do
  sleep @intro_duration + 8
  with_fx :ixi_techno, cutoff_min: 80 do
    with_fx :krush do
      with_fx :slicer, mix: 1 do |effect1|
        with_fx :panslicer, mix: 1, pan_min: -0.5, pan_max: 0.5 do |effect2|
          amp = [0, 1].ring
          (16).times do
            phase = [1.0 / 6, 1.0 / 8].choose
            control effect1, phase: phase
            control effect2, phase: phase
            sample [:vinyl_rewind, :vinyl_backspin].choose, rate: [2, 1, 3, 4, 0.5].choose * [1, -1].choose
            sleep 1
          end
        end
      end
    end
  end
end

def weirdo()
  sample :loop_weirdo, start: 0.13, finish: 0.33, attack: 0, decay: 0.1, rate: [0.75, 1, 1.5].choose, amp: 0.7, pan: rand(2) - 1.0
end


in_thread do
  sleep @intro_duration + 8 + 16
  with_fx :distortion, mix: 0.5 do
    (16).times do
      weirdo
      sleep 1.0/3
      
      6.times do
        sample [:drum_cymbal_closed, :drum_cymbal_pedal].choose,
          amp: [0, 0.5, 1, 0.7].choose
        sleep 1.0/9
      end
    end
  end
end

in_thread do
  sleep @intro_duration + 8 + 16
  with_fx :reverb, mix: 0.5 do
    
    (16).times do
      sample :drum_cymbal_soft, finish: 0.3
      sleep 1.0/3
      
      12.times do
        sample [:drum_cymbal_closed, :drum_cymbal_pedal].choose,
          amp: [0, 0, 0.5, 0.6].choose
        sleep 1.0/18
      end
    end
  end
end

in_thread do
  sleep @intro_duration + 8 + 16
  with_fx :ixi_techno, cutoff_min: 80, mix: 0.5 do
    (16).times do
      4.times do
        sample :drum_cowbell,
          amp: [ 0.3, 0.2, 0.1].choose
        sleep 1.0/4
      end
    end
  end
end

in_thread do
  sleep @intro_duration + 8 + 32
  with_fx :distortion, mix: 0.5 do
    (16).times do
      4.times do
        sample :bd_haus, amp: 0.2
        sleep 1.0/4
      end
    end
  end
end

in_thread do
  sleep @intro_duration + @main_duration1 + @main_duration2
  (12).times do
    with_fx :krush, mix: 0.05 do
      weirdo
    end
    sleep 1.0
  end
end

