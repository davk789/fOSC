/**
  * fOSC test synth
  */
s.queryAllNodes
s.sendMsg('n_set', 1, \gate, 0)


s.sendMsg('n_set', 400, \gate, 1)
s.sendMsg('n_set', 400, \gate, 0)
// !!! it looks like all of those silent hanging notes are actually sc bugs -- the note off message got to the synth, the voice released, but it wasn't freed from memory

(
SynthDef("fOSC_testSynth", {
	arg freq=200, amp=0.2, gate=1;
	var kEnv = EnvGen.kr(Env.asr(0.1, 1, 0.3, -3), gate, doneAction:2);
	var aSig = SinOsc.ar(freq, 0, kEnv * amp).pow(3);
	Out.ar(0, aSig.dup);
}).load(s, [1.0, 1.0]);

s.boot;
~start = { |time,r,msg|
	var node = msg[1];
	var freq = \freq.asSpec.map(msg[2]);
	var amp  = msg[3];//\amp.asSpec.map(msg[3]);
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

~addr = "192.168.1.103";
~onResp = OSCresponderNode(NetAddr(~addr, nil), '/fOSC/start', ~start).add;
~offResp = OSCresponderNode(NetAddr(~addr, nil), '/fOSC/end', ~end).add;
~moveResp = OSCresponderNode(NetAddr(~addr, nil), '/fOSC/move', ~move).add;
)
NetAddr.langPort
( //625
~tester = Task({
	var nodes = [      958,
      954,
      945,
      898,
      897,
      787,
      786,
      774,
      716,
      715,
      693,
      677,
      652,
      625,
      607,
      608,
      564,
      497,
      492,
      468,
      459,
      456,
      455,
      454,
      453,
      426,
      417,
      413,
      408,
      387,
      386,
      381,
      378,
      365,
      363,
      364,
      362,
      361,
      360,
      359,
      351,
      350,
      315,
      314,
      313,
      305,
      304,
      297,
      293,
      280,
      279,
      175,
      164,
      160,
      159,
      155,
      146,
      141,
      136,
      125,
      124,
      115,
      111,
      95,
      90,
      89,
      83,
      73,
      72,
      68,
      64,
      60,
      56,
      50,
      49,
      46,
      38,
      34,
      30,
      20,
];
	nodes.do{  |node,i|
		postln("node " ++ node ++ " starting. Setting params.");
		s.sendMsg(\n_set, node, \freq, 250, \amp, 0.2);
		1.0.wait;
		postln("node " ++ node ++ " opening gate");
		s.sendMsg(\n_set, node, \gate, 1);
		1.0.wait;
		postln("node " ++ node ++ " closing gate");
		s.sendMsg(\n_set, node, \gate, 0);
		0.25.wait;
	};
}).play;
)