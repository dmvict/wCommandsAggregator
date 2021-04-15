( function _CommandsAggregator_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( 'Tools' );
  _.include( 'wTesting' );
  require( '../../l7/commands/CommandsAggregator.s' );
}

const _global = _global_;
const _ = _global_.wTools;
const __ = _globals_.testing.wTools;

// --
// tests
// --

function perform( test )
{

  var Commands =
  {
    'with' : { ro : commandWith, h : 'With' },
    'list' : { ro : commandList, h : 'List' },
  }

  var aggregator = _.CommandsAggregator
  ({
    commands : Commands,
  }).form();

  /* */

  test.case = 'programPerform';
  track = 0;
  aggregator.programPerform({ program : '.with path to dir .list all' });
  test.identical( track, 2 );

  /* */

  test.case = 'instructionsPerform with empty propertiesMaps';
  track = 0;
  aggregator.instructionsPerform
  ({
    commands : '.with path to dir .list all',
    propertiesMaps : {},
  });
  test.identical( track, 2 );

  /* */

  test.case = 'instructionsPerform without propertiesMaps';
  track = 0;
  aggregator.instructionsPerform
  ({
    commands : '.with path to dir .list all',
  });
  test.identical( track, 2 );

  /* */

  test.case = 'instructionsPerform with string';
  track = 0;
  aggregator.instructionsPerform( '.with path to dir .list all' );
  test.identical( track, 2 );

  /* */

  test.case = 'instructionPerform with empty properties map';
  var track = 0;
  aggregator.instructionPerform
  ({
    command : '.with path to dir .list all',
    propertiesMap : Object.create( null ),
  });
  test.identical( track, 2 );

  /* */

  test.case = 'instructionPerform without peroperties map';
  var track = 0;
  aggregator.instructionPerform
  ({
    command : '.with path to dir .list all',
  });
  test.identical( track, 2 );

  /* */

  test.case = 'instructionPerform with string';
  var track = 0;
  aggregator.instructionPerform( '.with path to dir .list all' );
  test.identical( track, 2 );

  /* */

  test.case = 'instructionPerformParsed';
  var track = 0;
  aggregator.instructionPerformParsedLooking
  ({
    command : '.with path to dir .list all',
    commandName : '.with',
    instructionArgument : 'path to dir .list all',
  });
  test.identical( track, 2 );

  function commandWith( e )
  {

    test.description = 'integrity of the first event';
    test.identical( e.command, '.with path to dir .list all' );
    test.identical( e.commandName, '.with' );
    test.identical( e.instructionArgument, 'path to dir .list all' );
    test.true( e.aggregator === aggregator );
    test.true( _.objectIs( e.phraseDescriptor ) );
    test.identical( e.phraseDescriptor.phrase, 'with' );

    test.description = 'second command';
    let isolated = aggregator.instructionIsolateSecondFromArgument( e.instructionArgument );
    test.identical( isolated.instructionArgument, 'path to dir' );
    test.identical( isolated.secondInstruction, '.list all' );
    test.identical( isolated.secondInstructionName, '.list' );
    test.identical( isolated.secondInstructionArgument, 'all' );

    track = 1;

    debugger;
    e.aggregator.instructionPerform
    ({
      command : isolated.secondInstruction,
      propertiesMap : e.propertiesMap,
    });

  }

  function commandList( e )
  {
    let aggregator = e.aggregator;

    test.description = 'integrity of the second event';
    test.identical( e.command, '.list all' );
    test.identical( e.commandName, '.list' );
    test.identical( e.instructionArgument, 'all' );
    test.true( e.aggregator === aggregator );
    test.true( _.objectIs( e.phraseDescriptor ) );
    test.identical( e.phraseDescriptor.phrase, 'list' );

    track = 2;
  }

}

//

function instructionIsolateSecondFromArgument( test )
{

  var Commands =
  {
  }

  var aggregator = _.CommandsAggregator
  ({
    commands : Commands,
  }).form();

  test.case = 'with dot';
  var expected =
  {
    'instructionArgument' : '',
    'secondInstructionName' : '.module',
    'secondInstructionArgument' : '.shell git status',
    'secondInstruction' : '.module .shell git status',
  }
  var got = aggregator.instructionIsolateSecondFromArgument( '.module .shell git status' );
  test.identical( got, expected );

  test.case = 'no second';
  var expected =
  {
    'instructionArgument' : 'module git status',
    'secondInstructionArgument' : '',
  };
  var got = aggregator.instructionIsolateSecondFromArgument( 'module git status' );
  test.identical( got, expected );

  test.case = 'quoted doted instructionArgument';
  var expected =
  {
    'instructionArgument' : '".module" git status',
    'secondInstructionArgument' : '',
  };
  var got = aggregator.instructionIsolateSecondFromArgument( '".module" git status' );
  test.identical( got, expected );

  test.case = '"single with space/" .resources.list';
  var expected =
  {
    'instructionArgument' : 'single with space/',
    'secondInstructionName' : '.resources.list',
    'secondInstructionArgument' : '',
    'secondInstruction' : '.resources.list ',
  }
  var got = aggregator.instructionIsolateSecondFromArgument( '"single with space/" .resources.list' );
  test.identical( got, expected );

  test.case = 'some/path/Full.stxt .';
  var expected =
  {
    'instructionArgument' : 'some/path/Full.stxt .',
    'secondInstructionArgument' : '',
  }
  var got = aggregator.instructionIsolateSecondFromArgument( 'some/path/Full.stxt .' );
  test.identical( got, expected );

  test.case = 'some/path/Full.stxt ./';
  var expected =
  {
    'instructionArgument' : 'some/path/Full.stxt ./',
    'secondInstructionArgument' : '',
  }
  var got = aggregator.instructionIsolateSecondFromArgument( 'some/path/Full.stxt ./' );
  test.identical( got, expected );

}

//

function help( test )
{
  // let execCommand = () => {};
  let commandHelp = ( e ) => e.aggregator._commandHelp( e );

  var Commands =
  {
    'help' : { ro : commandHelp, h : 'Get help.' },
    'action' : { ro : () => {}, h : 'action some!' },
    'action first' : { ro : () => {}, h : 'This is action first' },
  }

  let logger2 = new _.LoggerToString();
  let logger1 = new _.Logger({ outputs : [ _global_.logger, logger2 ], outputRaw : 1 });

  var aggregator = _.CommandsAggregator
  ({
    commands : Commands,
    logger : logger1,
  }).form();

  test.case = 'trivial help'
  logger2.outputData = '';
  aggregator.instructionPerform({ command : '.help' });
  var expected =
  `
.help - Get help.
.action - action some!
.action.first - This is action first
`
  test.equivalent( logger2.outputData, expected );

  test.case = 'exact dotless'
  logger2.outputData = '';
  aggregator.instructionPerform({ command : '.help action' });
  var expected =
`
  .action - action some!
  .action.first - This is action first
`;
  test.equivalent( logger2.outputData, expected );

  test.case = 'exact with dot'
  logger2.outputData = '';
  aggregator.instructionPerform({ command : '.help action.' });
  var expected =
`
  .action - action some!
  .action.first - This is action first
`;
  test.equivalent( logger2.outputData, expected );

  test.case = 'exact, two words, dotless'
  logger2.outputData = '';
  aggregator.instructionPerform({ command : '.help action first' });
  var expected = '  .action.first - This is action first';
  test.identical( logger2.outputData, expected );

  test.case = 'exact, two words, with dot'
  logger2.outputData = '';
  aggregator.instructionPerform({ command : '.help .action.first' });
  var expected = '  .action.first - This is action first';
  test.identical( logger2.outputData, expected );

  test.case = 'part of phrase, dotless'
  logger2.outputData = '';
  aggregator.instructionPerform({ command : '.help first' });
  var expected = '  .action.first - This is action first\n  No command first';
  test.identical( logger2.outputData, expected );

  test.case = 'part of phrase, with dot'
  logger2.outputData = '';
  aggregator.instructionPerform({ command : '.help .first' });
  var expected = '  .action.first - This is action first\n  No command .first';
  test.identical( logger2.outputData, expected );

}

//

function helpWithLongHint( test )
{
  /* init */

  // let execCommand = () => {};
  let commandHelp = ( e ) => e.aggregator._commandHelp( e );

  var commands =
  {
    'help' :
    {
      ro : commandHelp,
      h : 'Get help.',
      lh : 'Get common help and help for separate command.',
    },
    'action' :
    {
      ro : () => {},
      h : 'action',
      lh : 'Use command action to execute some action.'
    },
    'action first' :
    {
      ro : () => {},
      h : 'action first',
      lh : 'Define actions which will be executed first.'
    },
  };

  let loggerToString = new _.LoggerToString();
  let logger = new _.Logger({ outputs : [ _global_.logger, loggerToString ], outputRaw : 1 });

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger,
  }).form();

  /* */

  test.case = 'without subject'
  loggerToString.outputData = '';
  aggregator.instructionPerform({ command : '.help' });
  var expected =
`
.help - Get common help and help for separate command.
.action - Use command action to execute some action.
.action.first - Define actions which will be executed first.
`;
  test.equivalent( loggerToString.outputData, expected );

  test.case = 'dotless single word subject - single possible method';
  loggerToString.outputData = '';
  aggregator.instructionPerform({ command : '.help action' });
  var expected =
`
  .action - Use command action to execute some action.
  .action.first - Define actions which will be executed first.
`;
  test.equivalent( loggerToString.outputData, expected );

  test.case = 'subject - two words, dotless'
  loggerToString.outputData = '';
  aggregator.instructionPerform({ command : '.help action first' });
  var expected = '  .action.first - Define actions which will be executed first.';
  test.identical( loggerToString.outputData, expected );

  test.case = 'exact, two words, with dot'
  loggerToString.outputData = '';
  aggregator.instructionPerform({ command : '.help .action.first' });
  var expected = '  .action.first - Define actions which will be executed first.';
  test.identical( loggerToString.outputData, expected );

  test.case = 'part of phrase, dotless'
  loggerToString.outputData = '';
  aggregator.instructionPerform({ command : '.help first' });
  var expected = '  .action.first - Define actions which will be executed first.\n  No command first';
  test.identical( loggerToString.outputData, expected );

  test.case = 'part of phrase, with dot'
  loggerToString.outputData = '';
  aggregator.instructionPerform({ command : '.help .first' });
  var expected = '  .action.first - Define actions which will be executed first.\n  No command .first';
  test.identical( loggerToString.outputData, expected );
}

//

function programPerform( test )
{
  let track = [];
  // let command1 = ( e ) => { track.push([ 'command1', e ]); };
  // let command2 = ( e ) => { track.push( e ); };
  let logger2 = new _.LoggerToString();
  let logger1 = new _.Logger({ outputs : [ _global_.logger, logger2 ] });

  /* - */

  test.case = 'commandsImplicitDelimiting : 0, without ;';

  clean();

  var commands =
  {
    'command1' : { ro : ( e ) => { track.push( e ); } },
    'command2' : { ro : ( e ) => { track.push( e ); } },
  };

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger : logger1,
    commandsImplicitDelimiting : 0,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : '.command1 arg1 arg2 .command2 arg3' });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 arg1 arg2 .command2 arg3',
      'commandName' : '.command1',
      'instructionArgument' : 'arg1 arg2 .command2 arg3',
      'subject' : 'arg1 arg2 .command2 arg3',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 arg1 arg2 .command2 arg3"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'commandsImplicitDelimiting : 0, with ;';

  clean();

  var commands =
  {
    'command1' : { ro : ( e ) => { track.push( e ); } },
    'command2' : { ro : ( e ) => { track.push( e ); } },
  };

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger : logger1,
    commandsImplicitDelimiting : 0,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : '.command1 arg1 arg2 ; .command2 arg3' });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 arg1 arg2',
      'commandName' : '.command1',
      'instructionArgument' : 'arg1 arg2',
      'subject' : 'arg1 arg2',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
    {
      'command' : '.command2 arg3',
      'commandName' : '.command2',
      'instructionArgument' : 'arg3',
      'subject' : 'arg3',
      'propertiesMap' : {},
      'parsedCommands' : null,
    }
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 arg1 arg2 ; .command2 arg3"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'commandsImplicitDelimiting : 1';

  clean();

  var commands =
  {
    'command1' : { ro : ( e ) => { track.push( e ); } },
    'command2' : { ro : ( e ) => { track.push( e ); } },
  };

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : '.command1 arg1 arg2 .command2 arg3' });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 arg1 arg2',
      'commandName' : '.command1',
      'instructionArgument' : 'arg1 arg2',
      'subject' : 'arg1 arg2',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
    {
      'command' : '.command2 arg3',
      'commandName' : '.command2',
      'instructionArgument' : 'arg3',
      'subject' : 'arg3',
      'propertiesMap' : {},
      'parsedCommands' : null,
    }
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 arg1 arg2 .command2 arg3"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'commandsImplicitDelimiting : 1, with "';

  clean();

  var commands =
  {
    'command1' : { ro : ( e ) => { track.push( e ); } },
    'command2' : { ro : ( e ) => { track.push( e ); } },
  };

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : '.command1 arg1 "arg2 .command2 arg3" .command2 "arg4 arg5" arg6' });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 arg1 "arg2 .command2 arg3"',
      'commandName' : '.command1',
      'instructionArgument' : 'arg1 "arg2 .command2 arg3"',
      'subject' : 'arg1 "arg2 .command2 arg3"',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
    {
      'command' : '.command2 "arg4 arg5" arg6',
      'commandName' : '.command2',
      'instructionArgument' : '"arg4 arg5" arg6',
      'subject' : '"arg4 arg5" arg6',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 arg1 "arg2 .command2 arg3" .command2 "arg4 arg5" arg6"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'commandsImplicitDelimiting : 1, with " and ;';

  clean();

  var commands =
  {
    'command1' : { ro : ( e ) => { track.push( e ); } },
    'command2' : { ro : ( e ) => { track.push( e ); } },
  };

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : '.command1 arg1 "arg2 .command2 arg3" .command2 "arg4 ; arg5" arg6 ; .command1 key:val' });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 arg1 "arg2 .command2 arg3"',
      'commandName' : '.command1',
      'instructionArgument' : 'arg1 "arg2 .command2 arg3"',
      'subject' : 'arg1 "arg2 .command2 arg3"',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
    {
      'command' : '.command2 "arg4 ; arg5" arg6',
      'commandName' : '.command2',
      'instructionArgument' : '"arg4 ; arg5" arg6',
      'subject' : '"arg4 ; arg5" arg6',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
    {
      'command' : '.command1 key:val',
      'commandName' : '.command1',
      'instructionArgument' : 'key:val',
      'subject' : '',
      'propertiesMap' : { 'key' : 'val' },
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 arg1 "arg2 .command2 arg3" .command2 "arg4 ; arg5" arg6 ; .command1 key:val"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'commandsImplicitDelimiting : 1, trivial triplet';

  clean();

  var commands =
  {
    'command1' : { ro : ( e ) => { track.push( e ); } },
    'command2' : { ro : ( e ) => { track.push( e ); } },
  };

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : '.command1 .command2 .command1' });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1',
      'commandName' : '.command1',
      'instructionArgument' : '',
      'subject' : '',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
    {
      'command' : '.command2',
      'commandName' : '.command2',
      'instructionArgument' : '',
      'subject' : '',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
    {
      'command' : '.command1',
      'commandName' : '.command1',
      'instructionArgument' : '',
      'subject' : '',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 .command2 .command1"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'complex without subject';

  clean();

  var commands =
  {
    'command1' : { ro : ( e ) => { track.push( e ); } },
    'command2' : { ro : ( e ) => { track.push( e ); } },
  };

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : '.command1 filePath:before/** ins:line sub:abc .command2 .command1' });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 filePath:before/** ins:line sub:abc',
      'commandName' : '.command1',
      'instructionArgument' : 'filePath:before/** ins:line sub:abc',
      'subject' : '',
      'propertiesMap' : { 'filePath' : 'before/**', 'ins' : 'line', 'sub' : 'abc' },
      'parsedCommands' : null,
    },
    {
      'command' : '.command2',
      'commandName' : '.command2',
      'instructionArgument' : '',
      'subject' : '',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
    {
      'command' : '.command1',
      'commandName' : '.command1',
      'instructionArgument' : '',
      'subject' : '',
      'propertiesMap' : {},
      'parsedCommands' : null,
    }
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 filePath:before/** ins:line sub:abc .command2 .command1"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'complex with subject';

  clean();

  var commands =
  {
    'command1' : { ro : ( e ) => { track.push( e ); } },
    'command2' : { ro : ( e ) => { track.push( e ); } },
  };

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : '.command1  some subject  filePath:before/** ins:line sub:abc .command2 .command1' });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 some subject  filePath:before/** ins:line sub:abc', /* qqq : does not look right! */
      'commandName' : '.command1',
      'instructionArgument' : 'some subject  filePath:before/** ins:line sub:abc',
      'subject' : 'some subject ',
      'propertiesMap' : { 'filePath' : 'before/**', 'ins' : 'line', 'sub' : 'abc' },
      'parsedCommands' : null,
    },
    {
      'command' : '.command2',
      'commandName' : '.command2',
      'instructionArgument' : '',
      'subject' : '',
      'propertiesMap' : {},
      'parsedCommands' : null,
    },
    {
      'command' : '.command1',
      'commandName' : '.command1',
      'instructionArgument' : '',
      'subject' : '',
      'propertiesMap' : {},
      'parsedCommands' : null,
    }
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1  some subject  filePath:before/** ins:line sub:abc .command2 .command1"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'several values';

  clean();

  var commands =
  {
    'command1' : { ro : ( e ) => { track.push( e ); } },
    'command2' : { ro : ( e ) => { track.push( e ); } },
  };

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : '.command1 a:1 b:2 a:3 a:x .command2 a:4 a:a' });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 a:1 b:2 a:3 a:x',
      'commandName' : '.command1',
      'instructionArgument' : 'a:1 b:2 a:3 a:x',
      'subject' : '',
      'propertiesMap' :
      {
        'a' : [ 1, 3, 'x' ],
        'b' : 2,
      },
      'parsedCommands' : null,
    },
    {
      'command' : '.command2 a:4 a:a',
      'commandName' : '.command2',
      'instructionArgument' : 'a:4 a:a',
      'subject' : '',
      'propertiesMap' :
      {
        'a' : [ 4, 'a' ],
      },
      'parsedCommands' : null,
    }
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 a:1 b:2 a:3 a:x .command2 a:4 a:a"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'quoted complex';

  clean();

  var commands =
  {
    'command1' : { ro : ( e ) => { track.push( e ); } },
    'command2' : { ro : ( e ) => { track.push( e ); } },
  };

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : `.command1 "path/key 1":val1 "path/key 2":val2 "path/key3":'val3'` });

  commandsClean();

  var exp =
  [
    {
      'command' : `.command1 "path/key 1":val1 "path/key 2":val2 "path/key3":'val3'`,
      'commandName' : '.command1',
      'instructionArgument' : `"path/key 1":val1 "path/key 2":val2 "path/key3":'val3'`,
      'subject' : '',
      'propertiesMap' : { 'path/key 2' : 'val2', 'path/key 1' : 'val1', 'path/key3' : 'val3' },
      'parsedCommands' : null,
    }
  ];
  test.identical( track, exp );
  var exp = `Command ".command1 "path/key 1":val1 "path/key 2":val2 "path/key3":'val3'"`;
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'notcommand prefix';

  clean();

  var commands =
  {
    'command1' : { ro : ( e ) => { track.push( e ); } },
    'command2' : { ro : ( e ) => { track.push( e ); } },
  };

  var aggregator = _.CommandsAggregator
  ({
    commands,
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
    changingExitCode : 0,
  }).form();

  debugger;
  test.shouldThrowErrorOfAnyKind
  (
    () => aggregator.programPerform({ program : 'notcommand .command1' }),
    ( err ) => { debugger; test.identical( _.strCount( err.message, 'Illformed command' ), 1 ) },
  );

  /* - */

  function commandsClean()
  {
    track.forEach( ( command ) =>
    {
      delete command.aggregator;
      delete command.phraseDescriptor;
    });
  }

  function clean()
  {
    logger2.outputData = '';
    track = [];
  }

}

//

function programPerformOptionSeveralValues( test )
{
  let track = [];
  // let command1 = ( e ) => { track.push( e ); };
  // let command2 = ( e ) => { track.push( e ); };
  let logger2 = new _.LoggerToString();
  let logger1 = new _.Logger({ outputs : [ _global_.logger, logger2 ] });

  /* - */

  test.case = 'severalValues - 1, commandsImplicitDelimiting - 0';

  clean();

  var aggregator = _.CommandsAggregator
  ({
    commands : { 'command1' : { ro : ( e ) => { track.push( e ); } } },
    logger : logger1,
    commandsImplicitDelimiting : 0,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : '.command1 arg1 v:1 r:1 v:2' });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 arg1 v:1 r:1 v:2',
      'commandName' : '.command1',
      'instructionArgument' : 'arg1 v:1 r:1 v:2',
      'subject' : 'arg1',
      'propertiesMap' : { 'v' : [ 1, 2 ], 'r' : 1 },
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 arg1 v:1 r:1 v:2"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'severalValues : 0, commandsImplicitDelimiting - 0';

  clean();

  var aggregator = _.CommandsAggregator
  ({
    commands : { 'command1' : { ro : ( e ) => { track.push( e ); } } },
    logger : logger1,
    commandsImplicitDelimiting : 0,
    propertiesMapParsing : 1,
    severalValues : 0,
  }).form();

  aggregator.programPerform({ program : '.command1 arg1 v:1 r:1 v:2', severalValues : 0 });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 arg1 v:1 r:1 v:2',
      'commandName' : '.command1',
      'instructionArgument' : 'arg1 v:1 r:1 v:2',
      'subject' : 'arg1',
      'propertiesMap' : { 'v' : 2, 'r' : 1 },
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 arg1 v:1 r:1 v:2"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'severalValues - 1, commandsImplicitDelimiting - 1';

  clean();

  var aggregator = _.CommandsAggregator
  ({
    commands : { 'command1' : { ro : ( e ) => { track.push( e ); } } },
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
  }).form();

  aggregator.programPerform({ program : '.command1 arg1 v:1 r:1 v:2' });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 arg1 v:1 r:1 v:2',
      'commandName' : '.command1',
      'instructionArgument' : 'arg1 v:1 r:1 v:2',
      'subject' : 'arg1',
      'propertiesMap' : { 'v' : [ 1, 2 ], 'r' : 1 },
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 arg1 v:1 r:1 v:2"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'severalValues : 0, commandsImplicitDelimiting - 1';

  clean();

  var aggregator = _.CommandsAggregator
  ({
    commands : { 'command1' : { ro : ( e ) => { track.push( e ); } } },
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
    severalValues : 0,
  }).form();

  aggregator.programPerform({ program : '.command1 arg1 v:1 r:1 v:2', severalValues : 0 });

  commandsClean();

  var exp =
  [
    {
      'command' : '.command1 arg1 v:1 r:1 v:2',
      'commandName' : '.command1',
      'instructionArgument' : 'arg1 v:1 r:1 v:2',
      'subject' : 'arg1',
      'propertiesMap' : { 'v' : 2, 'r' : 1 },
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = 'Command ".command1 arg1 v:1 r:1 v:2"';
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* - */

  function commandsClean()
  {
    track.forEach( ( command ) =>
    {
      delete command.aggregator;
      delete command.phraseDescriptor;
    });
  }

  function clean()
  {
    logger2.outputData = '';
    track = [];
  }

}

//

function programPerformOptionSubjectWinPathMaybe( test )
{
  let track = [];
  let command1 = ( e ) => { track.push( e ); };
  let command2 = ( e ) => { track.push( e ); };
  let logger2 = new _.LoggerToString();
  let logger1 = new _.Logger({ outputs : [ _global_.logger, logger2 ] });

  /* - */

  test.case = 'severalValues - 1, commandsImplicitDelimiting - 0';

  clean();

  var aggregator = _.CommandsAggregator
  ({
    commands : { 'command1' : { ro : ( e ) => { track.push( e ); } } },
    logger : logger1,
    commandsImplicitDelimiting : 0,
    propertiesMapParsing : 1,
  }).form();

  var subject = `${ _.path.nativize( _.path.current() ) }`;
  aggregator.programPerform({ program : `.command1 ${ subject } v:1 r:1 v:2`, subjectWinPathsMaybe : 1 });

  commandsClean();

  var exp =
  [
    {
      'command' : `.command1 ${ subject } v:1 r:1 v:2`,
      'commandName' : '.command1',
      'instructionArgument' : `${ subject } v:1 r:1 v:2`,
      'subject' : `${ subject }`,
      'propertiesMap' : { 'v' : [ 1, 2 ], 'r' : 1 },
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = `Command ".command1 ${ subject } v:1 r:1 v:2"`;
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'severalValues : 0, commandsImplicitDelimiting - 0';

  clean();

  var aggregator = _.CommandsAggregator
  ({
    commands : { 'command1' : { ro : ( e ) => { track.push( e ); } } },
    logger : logger1,
    commandsImplicitDelimiting : 0,
    propertiesMapParsing : 1,
  }).form();

  var subject = `${ _.path.nativize( _.path.current() ) }`;
  aggregator.programPerform({ program : `.command1 ${ subject } v:1 r:1 v:2`, severalValues : 0, subjectWinPathsMaybe : 1 });

  commandsClean();

  var exp =
  [
    {
      'command' : `.command1 ${ subject } v:1 r:1 v:2`,
      'commandName' : '.command1',
      'instructionArgument' : `${ subject } v:1 r:1 v:2`,
      'subject' : `${ subject }`,
      'propertiesMap' : { 'v' : 2, 'r' : 1 },
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = `Command ".command1 ${ subject } v:1 r:1 v:2"`;
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'severalValues - 1, commandsImplicitDelimiting - 1';

  clean();

  var aggregator = _.CommandsAggregator
  ({
    commands : { 'command1' : { ro : ( e ) => { track.push( e ); } } },
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
  }).form();

  var subject = `${ _.path.nativize( _.path.current() ) }`;
  aggregator.programPerform({ program : `.command1 ${ subject } v:1 r:1 v:2`, subjectWinPathsMaybe : 1 });

  commandsClean();

  var exp =
  [
    {
      'command' : `.command1 ${ subject } v:1 r:1 v:2`,
      'commandName' : '.command1',
      'instructionArgument' : `${ subject } v:1 r:1 v:2`,
      'subject' : `${ subject }`,
      'propertiesMap' : { 'v' : [ 1, 2 ], 'r' : 1 },
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = `Command ".command1 ${ subject } v:1 r:1 v:2"`;
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* */

  test.case = 'severalValues : 0, commandsImplicitDelimiting - 1';

  clean();

  var aggregator = _.CommandsAggregator
  ({
    commands : { 'command1' : { ro : ( e ) => { track.push( e ); } } },
    logger : logger1,
    commandsImplicitDelimiting : 1,
    propertiesMapParsing : 1,
    severalValues : 0,
  }).form();

  var subject = `${ _.path.nativize( _.path.current() ) }`;
  aggregator.programPerform({ program : `.command1 ${ subject } v:1 r:1 v:2`, severalValues : 0, subjectWinPathsMaybe : 1 });

  commandsClean();

  var exp =
  [
    {
      'command' : `.command1 ${ subject } v:1 r:1 v:2`,
      'commandName' : '.command1',
      'instructionArgument' : `${ subject } v:1 r:1 v:2`,
      'subject' : `${ subject }`,
      'propertiesMap' : { 'v' : 2, 'r' : 1 },
      'parsedCommands' : null,
    },
  ];
  test.identical( track, exp );
  var exp = `Command ".command1 ${ subject } v:1 r:1 v:2"`;
  test.identical( _.ct.stripAnsi( logger2.outputData ), exp );

  /* - */

  function commandsClean()
  {
    track.forEach( ( command ) =>
    {
      delete command.aggregator;
      delete command.phraseDescriptor;
    });
  }

  function clean()
  {
    logger2.outputData = '';
    track = [];
  }

}

//

function commandPropertiesAliases( test )
{
  let descriptor = null;

  /* */

  function command1( e )
  {
    descriptor = e;
  }
  var command = command1.command = Object.create( null );
  command.propertiesAliases =
  {
    verbosity : [ 'v' ],
    routine : [ 'r' ]
  }
  command.properties =
  {
    verbosity : 'verbosity',
    routine : 'routine',
  }

  /* */

  function commandAliasesArrayEmpty( e )
  {
    descriptor = e;
  }
  var command = commandAliasesArrayEmpty.command = Object.create( null );
  command.propertiesAliases =
  {
    verbosity : []
  }
  command.properties =
  {
    verbosity : 'verbosity'
  }

  /* */

  function commandAliasDuplication( e )
  {
    descriptor = e;
  }
  var command = commandAliasDuplication.command = Object.create( null );
  command.propertiesAliases =
  {
    verbosity : [ 'v', 'v' ]
  }
  command.properties =
  {
    verbosity : 'verbosity'
  }

  /* */

  function commandNoAliases( e )
  {
    descriptor = e;
  }
  var command = commandNoAliases.command = Object.create( null );
  command.properties =
  {
    verbosity : 'verbosity'
  }

  /* */

  function commandSeveralAliasesToSameProperty( e )
  {
    descriptor = e;
  }
  var command = commandSeveralAliasesToSameProperty.command = Object.create( null );
  command.propertiesAliases =
  {
    verbosity : [ 'v', 'v1' ]
  }
  command.properties =
  {
    verbosity : 'verbosity'
  }

  /* */

  let Commands =
  {
    'command' : { ro : command1, h : 'Test command' },
    'command.aliases.array.empty' : { ro : commandAliasesArrayEmpty, h : 'Test command' },
    'command.alias.duplication' : { ro : commandAliasDuplication, h : 'Test command' },
    'command.no.aliases' : { ro : commandNoAliases, h : 'Test command' },
    'command.several.aliases.to.same.property' : { ro : commandSeveralAliasesToSameProperty, h : 'Test command' },
  }

  let aggregator = _.CommandsAggregator
  ({
    commands : Commands,
    propertiesMapParsing : 1,
  }).form();

  /* */

  test.case = 'trivial';
  aggregator.programPerform( '.command v:1 r:abc' );
  var expected = { verbosity : 1, routine : 'abc' }
  test.identical( descriptor.propertiesMap, expected );

  /* */

  test.case = 'alias and property together';
  aggregator.programPerform( '.command verbosity:0 v:1 r:abc routine:xyz' );
  var expected = { verbosity : 1, routine : 'abc' }
  test.identical( descriptor.propertiesMap, expected );

  /* */

  test.case = 'no aliases';
  aggregator.programPerform( '.command.no.aliases v:1 verbosity:1' );
  var expected = { verbosity : 1, v : 1 }
  test.identical( descriptor.propertiesMap, expected );

  /* */

  test.case = 'several aliases to same property';
  aggregator.programPerform( '.command.several.aliases.to.same.property v:0 v1:1' );
  var expected = { verbosity : 1 }
  test.identical( descriptor.propertiesMap, expected );

  /* */

  if( !Config.debug )
  return;

  // qqq : adjust and extend test
  // test.case = 'aliases array is empty';
  // test.shouldThrowErrorSync
  // (
  //   () => aggregator.programPerform( '.command.aliases.array.empty v:1' ),
  //   ( err ) => test.identical( err.originalMessage, 'x' ),
  // )
  //
  // /* */
  //
  // test.case = 'alias duplication';
  // test.shouldThrowErrorSync
  // (
  //   () => aggregator.programPerform( '.command.alias.duplication v:1' ),
  //   ( err ) => test.identical( err.originalMessage, 'x' ),
  // )

  /* */

}

//

function formCommandsWithPhrases( test )
{
  let ready = _.take( null );
  let track = [];
  let logger2 = new _.LoggerToString();
  let logger1 = new _.Logger({ outputs : [ _global_.logger, logger2 ] });

  ready.then( () => act({ goodDelimeter : 1 }) );
  ready.then( () => act({ goodDelimeter : 0 }) );

  /* - */

  function act( env )
  {
    let ready = _.take( null );

    /* */

    test.case = `map of maps, ${__.entity.exportStringSolo( env )}`;

    clean();

    var command1 = ( e ) => { track.push([ 'command1', e ]); };
    var command2 = ( e ) => { track.push([ 'command2', e ]); };
    command2.command = { phrase : 'common command2' };
    if( !env.goodDelimeter )
    command2.command = { phrase : 'common.command2' };
    var command3 = ( e ) => { track.push([ 'command3', e ]); };
    command3.command = { phrase : 'common command3' };
    if( !env.goodDelimeter )
    command3.command = { phrase : '..common..command3.' };

    var commands =
    {
      'common command1' : { ro : command1 },
      'common command2' : { ro : command2 },
      'common command3' : { ro : command3 },
    };
    if( !env.goodDelimeter )
    commands =
    {
      '.common.command1.' : { ro : command1 },
      'common command2' : { ro : command2 },
      'common command3' : { ro : command3 },
    };

    var aggregator = _.CommandsAggregator
    ({
      commands,
      logger : logger1,
    }).form();

    ready.then( () => aggregator.programPerform( '.common.command1 subject opt1:a' ) );
    ready.then( () => aggregator.programPerform( '.common.command2 subject opt1:a' ) );
    ready.then( () => aggregator.programPerform( '.common.command3 subject opt1:a' ) );

    ready.then( () =>
    {

      var exp = [ 'command1', 'command2', 'command3' ];
      test.identical( _.select( track, '*/#0' ), exp );

      var exp =
`
Command ".common.command1 subject opt1:a"
Command ".common.command2 subject opt1:a"
Command ".common.command3 subject opt1:a"
`;
      test.equivalent( _.ct.stripAnsi( logger2.outputData ), exp );

      return null;
    });

    /* */

    test.case = `map of routines, ${__.entity.exportStringSolo( env )}`;

    clean();

    var command1 = ( e ) => { track.push([ 'command1', e ]); };
    var command2 = ( e ) => { track.push([ 'command2', e ]); };
    command2.command = { phrase : 'common command2' };
    if( !env.goodDelimeter )
    command2.command = { phrase : 'common.command2' };
    var command3 = ( e ) => { track.push([ 'command3', e ]); };
    command3.command = { phrase : 'common command3' };
    if( !env.goodDelimeter )
    command3.command = { phrase : '..common..command3.' };

    var commands =
    {
      'common command1' : command1,
      'common command2' : command2,
      'common command3' : command3,
    };
    if( !env.goodDelimeter )
    commands =
    {
      '.common.command1.' : command1,
      'common command2' : command2,
      'common command3' : command3,
    };

    var aggregator = _.CommandsAggregator
    ({
      commands,
      logger : logger1,
    }).form();

    ready.then( () => aggregator.programPerform( '.common.command1 subject opt1:a' ) );
    ready.then( () => aggregator.programPerform( '.common.command2 subject opt1:a' ) );
    ready.then( () => aggregator.programPerform( '.common.command3 subject opt1:a' ) );

    ready.then( () =>
    {

      var exp = [ 'command1', 'command2', 'command3' ];
      test.identical( _.select( track, '*/#0' ), exp );

      var exp =
`
Command ".common.command1 subject opt1:a"
Command ".common.command2 subject opt1:a"
Command ".common.command3 subject opt1:a"
`;
      test.equivalent( _.ct.stripAnsi( logger2.outputData ), exp );

      return null;
    });

    /* */

    test.case = `array of maps, ${__.entity.exportStringSolo( env )}`;

    clean();

    var command1 = ( e ) => { track.push([ 'command1', e ]); };
    var command2 = ( e ) => { track.push([ 'command2', e ]); };
    command2.command = { phrase : 'common command2' };
    if( !env.goodDelimeter )
    command2.command = { phrase : 'common.command2' };
    var command3 = ( e ) => { track.push([ 'command3', e ]); };
    command3.command = { phrase : 'common command3' };
    if( !env.goodDelimeter )
    command3.command = { phrase : '..common..command3.' };

    var commands =
    [
      { phrase : 'common command1.', ro : command1 },
      { phrase : 'common command2', ro : ( e ) => { track.push([ 'command2', e ]); } },
      { phrase : 'common command3', ro : command3 },
    ]
    if( !env.goodDelimeter )
    commands =
    [
      { phrase : '.common.command1.', ro : command1 },
      { phrase : 'common command2', ro : ( e ) => { track.push([ 'command2', e ]); } },
      { phrase : 'common command3', ro : command3 },
    ]

    var aggregator = _.CommandsAggregator
    ({
      commands,
      logger : logger1,
    }).form();

    ready.then( () => aggregator.programPerform( '.common.command1 subject opt1:a' ) );
    ready.then( () => aggregator.programPerform( '.common.command2 subject opt1:a' ) );
    ready.then( () => aggregator.programPerform( '.common.command3 subject opt1:a' ) );

    ready.then( () =>
    {

      var exp = [ 'command1', 'command2', 'command3' ];
      test.identical( _.select( track, '*/#0' ), exp );

      var exp =
`
Command ".common.command1 subject opt1:a"
Command ".common.command2 subject opt1:a"
Command ".common.command3 subject opt1:a"
`;
      test.equivalent( _.ct.stripAnsi( logger2.outputData ), exp );

      return null;
    });

    /* */

    test.case = `array of routines, ${__.entity.exportStringSolo( env )}`;

    clean();

    var command1 = ( e ) => { track.push([ 'command1', e ]); };
    command1.command = { phrase : 'common command1' };
    if( !env.goodDelimeter )
    command1.command = { phrase : 'common.command1' };
    var command2 = ( e ) => { track.push([ 'command2', e ]); };
    command2.command = { phrase : 'common command2' };
    if( !env.goodDelimeter )
    command2.command = { phrase : 'common.command2' };
    var command3 = ( e ) => { track.push([ 'command3', e ]); };
    command3.command = { phrase : 'common command3' };
    if( !env.goodDelimeter )
    command3.command = { phrase : '..common..command3.' };

    var commands =
    [
      command1,
      command2,
      command3,
    ];

    var aggregator = _.CommandsAggregator
    ({
      commands,
      logger : logger1,
    }).form();

    ready.then( () => aggregator.programPerform( '.common.command1 subject opt1:a' ) );
    ready.then( () => aggregator.programPerform( '.common.command2 subject opt1:a' ) );
    ready.then( () => aggregator.programPerform( '.common.command3 subject opt1:a' ) );

    ready.then( () =>
    {

      var exp = [ 'command1', 'command2', 'command3' ];
      test.identical( _.select( track, '*/#0' ), exp );

      var exp =
`
Command ".common.command1 subject opt1:a"
Command ".common.command2 subject opt1:a"
Command ".common.command3 subject opt1:a"
`;
      test.equivalent( _.ct.stripAnsi( logger2.outputData ), exp );

      return null;
    });

    /* */

    return ready;
  }

  /* - */

  function clean()
  {
    logger2.outputData = '';
    track = [];
  }

}

//

function customDelimeter( test )
{
  let ready = _.take( null );
  let track = [];
  let logger2 = new _.LoggerToString();
  let logger1 = new _.Logger({ outputs : [ _global_.logger, logger2 ] });

  ready.then( () => act({}) );

  /* - */

  function act( env )
  {
    let ready = _.take( null );

    /* */

    test.case = `in constructor, ${__.entity.exportStringSolo( env )}`;

    clean();

    var command1 = ( e ) => { track.push([ 'command1', e ]); };
    var command2 = ( e ) => { track.push([ 'command2', e ]); };

    var commands =
    {
      'common_command1' : { ro : command1 },
      'common_command2' : { ro : command2 },
    };

    var aggregator = _.CommandsAggregator
    ({
      commands,
      logger : logger1,
      delimeter : [ '_' ]
    });

    test.identical( aggregator.delimeter, [ '_' ] );

    aggregator.form();

    test.identical( aggregator.delimeter, [ '_' ] );
    test.identical( aggregator.vocabulary.delimeter, [ '_' ] );
    test.identical( aggregator.vocabulary.defaultDelimeter, '_' );

    ready.then( () => aggregator.programPerform( '_common_command1 subject opt1:a' ) );
    ready.then( () => aggregator.programPerform( '_common_command2 subject opt1:a' ) );

    ready.then( () =>
    {
      var exp = [ 'command1', 'command2' ];
      test.identical( _.select( track, '*/#0' ), exp );

      var expected =
`
Command "_common_command1 subject opt1:a"
Command "_common_command2 subject opt1:a"
`
      test.equivalent( _.ct.stripAnsi( logger2.outputData ), expected );

      return null;
    });

    /* */

    return ready;
  }

  /* - */

  function clean()
  {
    logger2.outputData = '';
    track = [];
  }

}

//

/* qqq : extend */
function badCommandsErrors( test )
{
  let ready = _.take( null );

  ready.then( () => act({}) );

  /* - */

  function act( env )
  {
    let ready = _.take( null );

    /* */

    test.case = `duplication, map of maps, ${__.entity.exportStringSolo( env )}`;

    var command2 = ( e ) => {};
    var commands =
    {
      'cmd1' : { ro : command2 },
      'cmd2' : { ro : command2 },
    };

    var aggregator = _.CommandsAggregator({ commands });

    var exp =
`Command "cmd1" already associated with a command aggregator. Each Command should be used only once.`
    test.shouldThrowErrorSync
    (
      () => aggregator.form(),
      ( err ) => test.equivalent( err.originalMessage, exp ),
    );

    /* */

    test.case = `duplication, map of routines, ${__.entity.exportStringSolo( env )}`;

    var command2 = ( e ) => {};
    var commands =
    {
      'cmd1' : command2,
      'cmd2' : command2,
    };

    var aggregator = _.CommandsAggregator({ commands });

    var exp =
`Command "cmd1" already associated with a command aggregator. Each Command should be used only once.`
    test.shouldThrowErrorSync
    (
      () => aggregator.form(),
      ( err ) => test.equivalent( err.originalMessage, exp ),
    );

    /* */

    test.case = `duplication, array of maps, ${__.entity.exportStringSolo( env )}`;

    var command2 = ( e ) => {};
    var commands =
    [
      { phrase : 'cmd1', ro : command2 },
      { phrase : 'cmd1', ro : command2 },
    ];

    var aggregator = _.CommandsAggregator({ commands });

    var exp =
`Command "cmd1" already associated with a command aggregator. Each Command should be used only once.`
    test.shouldThrowErrorSync
    (
      () => aggregator.form(),
      ( err ) => test.equivalent( err.originalMessage, exp ),
    );

    /* */

    test.case = `duplication, array of routines, ${__.entity.exportStringSolo( env )}`;

    var command2 = ( e ) => {};
    command2.command = { phrase : 'cmd2' }
    var commands =
    [
      command2,
      command2,
    ];

    var aggregator = _.CommandsAggregator({ commands });

    var exp =
`Command "cmd2" already associated with a command aggregator. Each Command should be used only once.`
    test.shouldThrowErrorSync
    (
      () => aggregator.form(),
      ( err ) => test.equivalent( err.originalMessage, exp ),
    );

    /* */

    return ready;
  }

  /* - */

}

badCommandsErrors.description =
`
  - error throwen if commands definitions has an problem
  - throwen error is descriptive
`

//

function helpForCommandWithAliases( test )
{

  let commandHelp = ( e ) => e.aggregator._commandHelp( e );

  function command1( e )
  {
  }
  var command = command1.command = Object.create( null );
  command.propertiesAliases =
  {
    verbosity : [ 'v' ],
    routine : [ 'r' ]
  }
  command.properties =
  {
    verbosity : 'verbosity',
    routine : 'routine',
  }

  function commandEmptyAliasesArray( e )
  {
  }
  var command = commandEmptyAliasesArray.command = Object.create( null );
  command.propertiesAliases =
  {
    verbosity : [],
  }
  command.properties =
  {
    verbosity : 'verbosity',
    routine : 'routine',
  }

  function commandAliasDuplicated( e )
  {
  }
  var command = commandAliasDuplicated.command = Object.create( null );
  command.propertiesAliases =
  {
    verbosity : [ 'v' ],
    routine : [ 'v' ]
  }
  command.properties =
  {
    verbosity : 'verbosity',
    routine : 'routine',
  }

  /* */

  let Commands =
  {
    'help' : { ro : commandHelp, h : 'Get help.' },
    'command' : { ro : command1, h : 'Test command' },
    'command.aliases.array.empty' : { ro : commandEmptyAliasesArray, h : 'Test command' },
    'command.alias.duplicated' : { ro : commandAliasDuplicated, h : 'Test command' },
  }

  let logger2 = new _.LoggerToString();
  let logger1 = new _.Logger({ outputs : [ _global_.logger, logger2 ], outputRaw : 1 });

  let aggregator = _.CommandsAggregator
  ({
    commands : Commands,
    logger : logger1,
  }).form();

  /* */

  test.case = 'trivial'
  logger2.outputData = '';
  aggregator.instructionPerform({ command : '.help command' });
  var expected =
`
  .command - Test command
  .command.aliases.array.empty - Test command
  .command.alias.duplicated - Test command
    v : verbosity
    verbosity : verbosity
    r : routine
    routine : routine
`
  test.equivalent( logger2.outputData, expected );
  console.log( logger2.outputData );

  /* */

  if( !Config.debug )
  return;

  test.shouldThrowErrorSync( () => aggregator.instructionPerform({ command : '.help command.aliases.array.empty' }) )
  test.shouldThrowErrorSync( () => aggregator.instructionPerform({ command : '.help command.alias.duplicated' }) )
}

// --
// declare
// --

const Proto =
{

  name : 'Tools.mid.CommandsAggregator',
  silencing : 1,

  tests :
  {

    perform,
    instructionIsolateSecondFromArgument,
    help,
    helpWithLongHint,
    programPerform,
    programPerformOptionSeveralValues,
    programPerformOptionSubjectWinPathMaybe,
    commandPropertiesAliases,
    formCommandsWithPhrases,
    customDelimeter,
    badCommandsErrors,
    helpForCommandWithAliases

  }

}

/* xxx : write test : should not perform instruction if ends on dot */
/* xxx : implement field importance */
/* xxx : implement option::prefferedHeight for help */
/* xxx : implement delayed subphrasesMap evaluation */
/* xxx : cache subphrasesMap to storage and maybe not only subphrasesMap */
/* xxx : implement test with proces.start() */

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
