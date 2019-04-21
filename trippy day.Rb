
use_bpm 60
def my_live_loop(name)
  in_thread do
    with_fx :level, amp:0 do |level_control|
      set name.to_s.concat("_level"), level_control
      loop do
        yield
      end
    end
  end
end

def linear_slide(from, to, duration)
  ((0...duration).to_a.map {|x| x * (to - from) / duration + from}).ring
end

live_loop :chord_progression, delay: -1.0 / 32 do
  set :chords, [ chord(:D2, :minor), chord(:F2, :major), chord(:D2, :minor7), chord(:G1, :m11)].ring.shuffle
  set :chords2, [chord(:a2, :minor),
                 chord(:a2, :minor7)].ring.shuffle
  8.times do
    set :achord, get[:chords].tick(:maj)
    4.times do
      sleep 1.0/ 8
      set :chord2, get[:chords2].tick(:min)
      sleep 1.0/ 8
    end
  end
end

my_live_loop :airy do
  octaves = [0, 1, 2, 4].ring.shuffle.mirror
  arpeggio = [1, 2, 3, 4, 5, 7].shuffle.ring
  sounds = [:elec_triangle, :elec_pop, :perc_bell2].ring.shuffle
  with_fx :slicer, phase: 1, wave: 1, pulse_width: 0.04, invert_wave: 1 do
    8.times do
      sound1 = sounds.tick(:s)
      sound2 = sounds.tick(:s)
      4.times do
        2.times do
          note = get[:achord][arpeggio.tick(:a)] + 12 * octaves.tick(:o)
          sample sound1, finish: 0.7, rpitch: note
          synth :fm, note: note, depth: 3, amp: 0.1 + rand(0.5)
          sleep 1.0/ 8
        end
        2.times do
          note = get[:chord2][arpeggio.tick(:a)] + 12 * octaves.look(:o)
          sample sound2, rpitch: note, finish: 0.7, rate: [1, -1].choose
          synth :mod_fm, note: note, amp: rand(0.5)
          sleep 1.0/ 8
        end
      end
    end
  end
end

my_live_loop :airy2 do
  octaves = [0, 1, 2].ring.shuffle.mirror
  arpeggio = [1, 2, 3, 4].shuffle.ring
  sounds = [:elec_triangle, :elec_pop, :perc_bell2].ring.shuffle
  with_fx :slicer, phase: 1, wave: 1, pulse_width: 0.05, invert_wave: 1 do
    with_fx :panslicer, phase: 8, wave: 3 do
      with_fx :reverb do
        8.times do
          sound1 = sounds.tick(:s)
          sound2 = sounds.tick(:s)
          4.times do
            2.times do
              note = get[:achord][arpeggio.tick(:a)] + 12 * octaves.tick(:o)
              sample sound1, finish: 0.9, rate: 1.5, rpitch: note
              synth :blade, note: note, depth: 3, amp: 0.5 + rand(0.4), vibrato_depth: 1, vibrato_rate: 10
              sleep 1.0/ 8
            end
            2.times do
              note = get[:chord2][arpeggio.tick(:a)] + 12 * octaves.look(:o)
              sample sound2, rpitch: note, finish: 0.9, rate: [1.5, -1.5].choose
              synth :blade, note: note, amp: 0.4 + rand(0.5), vibrato_depth: 1, vibrato_rate: 5
              sleep 1.0/ 8
            end
          end
        end
        
      end
    end
  end
end


my_live_loop :pan do
  with_fx :slicer, phase: 1, wave: 1, pulse_width: 0.04, invert_wave: 1 do
    with_fx :ixi_techno, cutoff_min: 90, phase: 8 do
      with_fx :gverb do
        pan = rand(1.6) - 0.8
        8.times do
          4.times do
            2.times do
              synth :blade, note: get[:achord].map{|n| n + 24}, amp: 0.5 + rand(0.05), pan: pan
              sleep 1.0/ 8
            end
            2.times do
              synth :blade, note: get[:chord2].map{|n| n + 24}, amp: 0.4 + rand(0.05), pan: pan
              sleep 1.0/ 8
            end
          end
        end
      end
    end
  end
end


my_live_loop :bass do
  8.times do
    with_fx :tanh, mix: 0.2 do
      synth :hoover, note: get[:achord].choose, attack: 0, release: 0.3
      synth :hollow, note: get[:achord].choose - 12, attack: 0, release: 0.7
      sleep 1
      synth :hoover, note: get[:chord2].choose, attack: 0, release: 0.3
      synth :hollow, note: get[:chord2].choose - 12, attack: 0, release: 0.7
      sleep 1
    end
  end
end

my_live_loop :drum do
  sample :sn_generic, finish: 0.3, rate: [1, 1, -1].choose
  sample :perc_door, finish: 0.05
  sleep 1
end

my_live_loop :drum2 do
  sleep 0.5
  sample :mehackit_robot3, finish: 0.1, attack: 0, release: 0.07, rate: [1, -1].choose,
    rpitch: [10, 4].choose
  sleep [0.125, 0.5].choose
end

my_live_loop :drum3 do
  8.times do
    sample :bd_tek, finish: 0.1, rate: [2, 1, 0.5, 0.25].ring.reflect.tick
    sleep 1.0 / 16
    if one_in(8)
      sample :bd_haus, finish: 0.1, rate: [2, 1, 0.5, 0.25].ring.reflect.tick
    end
    sleep 1.0 / 16
  end
end

my_live_loop :intro do
  use_synth :blade
  play chord(:A2, :minor7).choose, vibrato_depth: 1, vibrato_rate: 19, release: 1.2
  sleep 1
end

my_live_loop :glitch do
  with_fx :reverb, room: 0.8 do
    sample [:glitch_perc5, :glitch_perc4, :glitch_perc3].choose, pan: rand(1.6) - 0.8
    sleep 1 + rand_i(7)
  end
end


def mix()
  set_volume! 1
  increase = linear_slide(0.2, 1, 9)
  8.times do
    control get["drum_level"], amp: increase.tick(:r1)
    control get["bass_level"], amp: increase.look(:r1)
    control get["drum2_level"], amp: 1
    sleep 1
  end
  sample :glitch_perc5
  control get["drum_level"], amp: 1
  control get["bass_level"], amp: 1
  
  increase = linear_slide(0.3, 1, 21)
  20.times do
    control get["drum3_level"], amp: increase.tick(:r2)
    sleep 1
  end
  sample :glitch_perc4
  control get["drum3_level"], amp: 1
  
  decrease = linear_slide(0.1, 1.0, 22).reverse
  20.times do
    control get["intro_level"], amp: decrease.tick(:r3)
    sleep 1
  end
  control get["intro_level"], amp: 0
  sample :glitch_perc5
  increase = linear_slide(0.0, 0.1, 8)
  8.times do
    control get["pan_level"], amp: increase.tick(:r4)
    sleep 1
  end
  increase = linear_slide(0.1, 1, 8)
  8.times do
    control get["pan_level"], amp: increase.tick(:r5)
    sleep 1
  end
  control get["pan_level"], amp: 1
  sleep 16
  sample :glitch_perc5
  control get["airy_level"], amp: 0.2
  sleep 12
  increase = linear_slide(0.2, 0.6, 9)
  4.times do
    control get["airy_level"], amp: increase.tick(:r6)
    sleep 0.5
  end
  control get["airy_level"], amp: 0.6
  decrease = linear_slide(0.5, 1.0, 22).reverse
  20.times do
    control get["pan_level"], amp: decrease.tick(:r7)
    sleep 1
  end
  control get["pan_level"], amp: 0.5
  control get["glitch_level"], amp: 1
  sleep 23
  decrease = linear_slide(0.3, 1.0, 22).reverse
  control get["pan_level"], amp: 0
  control get["airy_level"], amp: 0
  sample :drum_cymbal_open, finish: 0.7
  sample :drum_cymbal_closed, finish: 0.7
  sample :drum_cymbal_pedal, finish: 0.7
  sample :bd_zome, finish: 0.7
  
  20.times do
    control get["intro_level"], amp: decrease.tick(:r8)
    sleep 1
  end
  control get["intro_level"], amp: 0
  sleep 4
  control get["pan_level"], amp: 0.5
  control get["airy_level"], amp: 0.6
  
  increase = linear_slide(0.0, 0.8, 22)
  increase2 = linear_slide(0.2, 0.5, 22).reverse
  20.times do
    control get["airy2_level"], amp: increase.tick(:r9)
    control get["pan_level"], amp: increase2.tick(:r9)
    sleep 1
  end
  control get["pan_level"], amp: 0.2
  control get["airy2_level"], amp: 0.8
  sleep 24
  decrease = linear_slide(0.0, 1.0, 22).reverse
  20.times do
    set_volume! decrease.tick(:r10)
    sleep 2
  end
end

sleep 7.92
mix
