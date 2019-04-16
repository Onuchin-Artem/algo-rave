use_bpm 60
live_loop :chord_progression, delay: -1.0 / 32 do
  @chords = [ chord(:D2, :minor), chord(:F2, :major), chord(:D2, :minor7), chord(:G1, :m11)].ring
  @chords2 = [chord(:a2, :minor),
              chord(:a2, :minor7)].ring.shuffle
  8.times do
    @achord = @chords.tick(:maj)
    4.times do
      sleep 1.0/ 8
      @chord2 = @chords2.tick(:min)
      sleep 1.0/ 8
    end
  end
end

live_loop :airy do
  octaves = [0, 1, 2].ring.shuffle.mirror
  arpeggio = [1, 2, 3, 4, 5, 7].shuffle.ring
  sounds = [:elec_triangle, :elec_pop, :perc_bell2].ring.shuffle
  with_fx :slicer, phase: 1, wave: 1, pulse_width: 0.04, invert_wave: 1 do
    8.times do
      sound1 = sounds.tick(:s)
      sound2 = sounds.tick(:s)
      4.times do
        note = @achord[arpeggio.tick(:a)] + 12 * octaves.tick(:o)
        sample sound1, finish: 0.7, rpitch: note
        synth :fm, note: note, depth: 3
        sleep 1.0/ 8
        note = @chord2[arpeggio.tick(:a)] + 12 * octaves.look(:o)
        sample sound2, rpitch: note, finish: 0.7, rate: [1, -1].choose
        synth :mod_fm, note: note
        sleep 1.0/ 8
      end
    end
  end
end


live_loop :pan do
  with_fx :slicer, phase: 1, wave: 1, pulse_width: 0.04, invert_wave: 1 do
    with_fx :ixi_techno, cutoff_min: 90, phase: 8 do
      with_fx :gverb do
        pan = rand(1) - 0.5
        8.times do
          4.times do
            print @achord
            synth :blade, note: @achord.map{|n| n + 24}, amp: 0.5 + rand(0.05), pan: pan
            sleep 1.0/ 8
            synth :blade, note: @chord2.map{|n| n + 24}, amp: 0.4 + rand(0.05), pan: pan
            sleep 1.0/ 8
          end
        end
      end
    end
  end
end


live_loop :bass do
  8.times do
    with_fx :tanh, mix: 0.2 do
      synth :hoover, note: @achord.choose, attack: 0, release: 0.3
      synth :hollow, note: @achord.choose - 12, attack: 0, release: 0.7
      sleep 1
    end
  end
end

live_loop :drum do
  sample :sn_generic, finish: 0.3, rate: [1, 1, -1].choose
  sample :perc_door, finish: 0.05
  sleep 1
end

live_loop :drum2 do
  sleep 0.5
  sample :loop_3d_printer, finish: 0.1, attack: 0, release: 0.07, rate: [1, -1].choose,
    rpitch: [10, 4].choose
  sleep [0.125, 0.5].choose
end

live_loop :drum3 do
  8.times do
    sample :bd_tek, finish: 0.1, rate: [2, 1, 0.5, 0.25].ring.reflect.tick
    sleep 1.0 / 16
    if one_in(8)
      sample :bd_haus, finish: 0.1, rate: [2, 1, 0.5, 0.25].ring.reflect.tick
    end
    sleep 1.0 / 16
  end
end
