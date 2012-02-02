/**
  * fOSC test synth
  */
  

(
SynthDef("fOSC_testSynth", {
	arg freq=200, amp=0.2, gate=1;
	var kEnv = EnvGen.kr(Env.asr(0.1, 1, 0.3, -3), gate);
	var aSig = SinOsc.ar(freq, 0, kEnv * amp).pow(3);
	Out.ar(0, aSig.dup);
}).load(s, [0.1, 0.1]);
)

(
s.boot;
~start = { |time,r,msg|
	var node = msg[1];
	var freq = \freq.asSpec.map(msg[2]);
	var amp  = \amp.asSpec.map(msg[3]);
	s.sendMsg('s_new', 'fOSC_testSynth', node, 0, 1, 'freq', freq, 'amp', amp);
};

~end = { |time,r,msg|
	var node = msg[1];
	s.sendMsg('n_set', node, 'gate', 0);	
};

~move = { |time,r,msg|
	var node = msg[1];
	var freq = \freq.asSpec.map(msg[2]);
	var amp  = \amp.asSpec.map(msg[3]);
	s.sendMsg('n_set', node, 'freq', freq, 'amp', amp);
};


~onResp = OSCresponderNode(NetAddr("192.168.1.107", nil), '/fOSC/start', ~start).add;
~offResp = OSCresponderNode(NetAddr("192.168.1.107", nil), '/fOSC/end', ~end).add;
~moveResp = OSCresponderNode(NetAddr("192.168.1.107", nil), '/fOSC/move', ~move).add;
)

