s.boot;

// Ayuda de SampleTexto
SampleTexto2.help;

// Crea una instancia de SampleTexto
~a = SampleTexto2.new;

// Arrastra tu carpeta de sonidos después de los dos puntos y declara la línea para cargar los sonidos
~a.init(path: thisProcess.nowExecutingPath.dirname +/+ "/sonidos");

// Toca el sonido del índice cero
~a.st(2).play;

// Separa los sonidos en mono y estéreo
~a.stsel;

// Toca un sonido mono en el índice 0
~a.stm(1).play;

// Toca un sonido estéreo en el índice 0
~a.sts(1).play;

// Da información de los sonidos de la carpeta
~a.info;

// Crea un synth mono para cada sonido de la carpeta
~a.monosynth();

// Crea un synth estéreo para cada sonido de la carpeta
~a.stereosynth();

// Define el procesamiento de sonido: Reverberación y Delay
(
// Reverberación - bus 9
SynthDef(\rev, {|in = 9, mix = 0.4, room = 0.9, damp = 0.1, amp = 1, gate = 1, out = 0|
	var sen, env;
	sen = FreeVerb.ar(InFeedback.ar(in, 2), mix, room, damp, amp);
	env = EnvGen.kr(Env.asr(0.01, 1, 0.1), gate, doneAction: 0);
	Out.ar(out, sen * env);
}).add;

// Delay - bus 11, mdt = maxdelayTime, dt = delayTime, dct = decayTime
SynthDef(\del, {|in = 11, mdt = 0.3, dt = 0.25, dct = 2, gate = 1, out = 0|
	var del, env;
	del = CombL.ar(InFeedback.ar(in, 2), mdt, dt, dct);
	env = EnvGen.kr(Env.asr(0.01, 1, 0.01), gate, doneAction: 0);
	Out.ar(out, del * env);
}).add;
);

// Activa los efectos: Reverberación y Delay
(
~rev = Synth(\rev); // 9 Reverberación
~del = Synth(\del); // 11 Delay
);

// Modifica los efectos: Reverberación y Delay
~rev.set(\mix, 0.5, \room, 0.5, \damp, 0.5);
~del.set(\mdt, 0.5, \dt, 0.25, \dct, 3);

// Define el patrón para reproducir los sonidos secuencialmente y controla el tempo
TempoClock.default.tempo = 1.4;
// -36 DO,
// Define el Pbind para reproducir el sonido mono desde el índice 0 LA GUITARRITA
(
SynthDef(\pitchShift, { |in = 0, out = 0, shift = 0.5, timeDispersion = 0.1|
    var source = In.ar(in, 2);
    var shifted = PitchShift.ar(source, 0.2, shift, 0, timeDispersion);
    Out.ar(out, shifted);
}).add;

SynthDef(\reverb, { |in = 0, mix = 0.3, room = 0.5, damp = 0.5, out = 0|
    var source = In.ar(in, 2);
    var rev = FreeVerb.ar(source, mix, room, damp);
    Out.ar(out, rev);
}).add;

SynthDef(\delay, { |in = 0, maxdelay = 0.5, delaytime = 0.25, decaytime = 2, out = 0|
    var source = In.ar(in, 2);
    var del = CombL.ar(source, maxdelay, delaytime, decaytime);
    Out.ar(out, del);
}).add;

SynthDef(\m0, { |freq = 440, amp = 0.3, at = 0.1, rel = 0.9, out = 0|
    var env = EnvGen.kr(Env.perc(at, rel), doneAction: 2);
    var sig = SinOsc.ar(freq) * env * amp;
    Out.ar(out, sig);
}).add;
)

~pitchShiftBus = Bus.audio(s, 2);
~reverbBus = Bus.audio(s, 2);
~delayBus = Bus.audio(s, 2);

~pitchShift = Synth(\pitchShift, [\in, ~pitchShiftBus, \out, ~reverbBus, \shift, 0.5]);
~reverb = Synth(\reverb, [\in, ~reverbBus, \out, ~delayBus]);
~delay = Synth(\delay, [\in, ~delayBus, \out, 0]);

(
~accompaniment = Pdef(\accompaniment, Pbind(
    \instrument, \m0,
    \dur, 2,
    \note, Pseq([10, 12, 16, 3, 6, 10, 10, 13, 17], inf),
    \at, 0.5,
    \rel, 0.9,
    \amp, 0.1,
    \out, ~pitchShiftBus
));
)
~accompaniment.play; //***********************************************************************************
~accompaniment.stop;
// Define el Pbind para reproducir el sonido mono desde el índice 1 HIHAT *********************************
(
~s2 = Pdef(\s2, Pbind(
    \instrument, \m1,
    \dur, 1/2,
    \rate, Pseq([-40, -42, -40, -40, -42, -40], inf).midicps,
    \sp, Pseq([1, 1, 1, 1, Pn(0.1)].mirror, inf),
    \amp, 2,
    \out, 0
));
)
~s2.play.quant(4);
~s2.stop;
// Define el Pbind para reproducir gritos****************************************************************
(
SynthDef(\samplePlayer, { |bufnum, amp = 0.9, out = 0|
    var sig = PlayBuf.ar(2, bufnum, rate: 0.9, doneAction: 2) * amp; // rate: 0.5 para el efecto rebajado
    sig = FreeVerb.ar(sig, mix: 0.5, room: 0.9, damp: 0.5); // Añadir reverb
    Out.ar(out, sig);
}).add;
)
(
~s3 = Pdef(\s3, Pbind(
    \instrument, \samplePlayer,
    \bufnum, ~a.st(2).bufnum, // Obtener el buffer del sonido en el índice 2
    \dur, Pseq([1, Rest(9)], inf),
    \amp, 0.9,
    \out, 0
));
)
~s3.play.quant(1);
~s3.stop;
// Define el Pbind para reproducir el sonido estéreo desde el índice 1 Tambores fuertes
~s4 = Pdef(\s4, Pbind(
	\instrument, \s1,
	\dur, 1/8,
	\rate, Pseq([-60, -70, -60, -70].pyramid, inf).midicps,
	\sp, Pseq([1, 1, 1, 1, Pn(0.15, 4)].mirror, inf),
	\amp, 2,
	\out, 0
));
~s4.play.quant(4);
~s4.stop;
// Define el Pbind para reproducir el sonido estéreo desde el índice 2 Multiples instrumentos
~s5 = Pdef(\s5, Pbind(
	\instrument, \s5,
	\dur, 1/8,
	\rate, Pseq([-25, -20, -15, -10].pyramid, inf).midicps,
	\sp, Pseq([0.1, 0.2, 0.1, 0, Pn(0.15, 4)].mirror, inf),
	\amp, 0.6,
	\out, 0
));
~s5.play.quant(4);
~s5.stop;
// Define el Pbind para reproducir el sonido estéreo desde el índice 3  tarola ******************************
(~s6 = Pdef(\s6, Pbind(
	\instrument, \s3,
	\dur, 1,
	\rate, Pseq([-40, -40, -40, -40].mirror, inf).midicps,
	\sp, Pseq([0.1, 0.2, 0.1, 0.2, Pn(0.15, 4)].mirror, inf),
	\amp, 2,
	\out, 0
));
)
~s6.play.quant(4);
~s6.stop;
// Define el Pbind para reproducir el sonido estéreo desde el índice 4 tarima
~s7 = Pdef(\s7, Pbind(
	\instrument, \s4,
	\dur, 1/4,
	\rate, Pseq([-32, -30, -28, -27].pyramid, inf).midicps,
	\sp, Pseq([0.1, 0.2, 0.1, 0, Pn(0.15, 4)].mirror, inf),
	\amp, 0.6,
	\out, 0
));
~s7.play.quant(4);
~s7.stop;
// Base de la canción ***************************************************************************************
(
SynthDef(\tri, {|freq=210, pan=0, at=0.2, rel=0.5, amp=0.3, out=0|
	var sen, paneo, env;
	sen=LFTri.ar(freq, amp);
	paneo=Pan2.ar(sen, pan);
	env=EnvGen.kr(Env.new([1,1,0], [at, rel]), doneAction:2);
	Out.ar(out, paneo * env)
}).add
);
(
TempoClock.default.tempo = 1;
Pdef(\trisec, Pbind(
	\instrument, \tri,
	\dur, Pseq([1/1/2],inf),
	\note,  Pseq([10,12,16,3,6,10,10,13,17],inf)
)).stop
)