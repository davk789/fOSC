/**
  * fOSC test synth
  */
//s.queryAllNodes
//s.sendMsg('n_set', 1, \gate, 0)

(
SynthDef("fOSC_testSynth", {
	arg freq=200, amp=0.2, gate=1;
	var kEnv = EnvGen.kr(Env.asr(0.1, 1, 0.3, -3), gate, doneAction:2);
	var aSig = SinOsc.ar(freq, 0, kEnv * amp).pow(3);
	Out.ar(0, aSig.dup);
}).load(s, [1.0, 1.0]);
)

(
s.boot;
~start = { |time,r,msg|
	var node = msg[1];
	var freq = \freq.asSpec.map(msg[2]);
	var amp  = \amp.asSpec.map(msg[3]);
	msg.postln;
	s.sendMsg('s_new', 'fOSC_testSynth', node, 0, 1, 'freq', freq, 'amp', amp);
};

~end = { |time,r,msg|
	var node = msg[1];
	msg.postln;
	s.sendMsg('n_set', node, 'gate', 0);	
};

~move = { |time,r,msg|
	var node = msg[1];
	var freq = \freq.asSpec.map(msg[2]);
	var amp  = \amp.asSpec.map(msg[3]);
	msg.postln;
	s.sendMsg('n_set', node, 'freq', freq, 'amp', amp);
};

~addr = "192.168.1.20";
~onResp = OSCresponderNode(NetAddr(~addr, nil), '/fOSC/start', ~start).add;
~offResp = OSCresponderNode(NetAddr(~addr, nil), '/fOSC/end', ~end).add;
~moveResp = OSCresponderNode(NetAddr(~addr, nil), '/fOSC/move', ~move).add;
)

