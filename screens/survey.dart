import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import './quiz.dart';
import './result.dart';

class Survey extends StatefulWidget {
  @override
  _SurveyState createState() => _SurveyState();
}



class _SurveyState extends State<Survey> {
  final _questions = const [
    {
      'questionText': 'Are you ready to start the survey?',
      'answers': [
        {'text': 'Yes', 'score': 0},
      ],
    },
    {
      'questionText': 'Q1. Had you have your lunch or breakfast?',
      'answers': [
        {'text': 'Yes', 'score': 10},
        {'text': 'No', 'score': 0},
        {'text': 'Very little only', 'score': 10},
      ],
    },
    {
      'questionText': 'Q2. In the last 3 days have you taken medication(including Aspirin) or alcohol ?(vitamins and birth control are excluded)',
      'answers': [
        {'text': 'Yes', 'score': 0},
        {'text': 'No', 'score': 10},
      ],
    },
    {
      'questionText': ' Q3. When is your last blood donation?',
      'answers': [
        {'text': 'Less than 1 month', 'score': 0},
        {'text': 'Less than 3 month', 'score': 0},
        {'text': 'More than 3 month', 'score': 10},
        {'text': 'This is my first time', 'score': 10},
      ],
    },
    {
      'questionText': 'Q4. In the last 6 months have you consulted a doctor for a health problem, had surgery or medical treatment?',
      'answers': [
        {'text': 'Yes', 'score': 0},
        {'text': 'No', 'score': 10},
        // {'text': 'Just for some simple medical check', 'score': 5},
      ],
    },
    {
      'questionText':
      'Q5. Are you feeling well today?',
      'answers': [
        {
          'text': 'Yes',
          'score': 10,
        },
        {'text': 'No', 'score': 0},
      ],
    },
  ];

  var _questionIndex = 0;
  var _totalScore = 0;

  AuthUser _user;
  @override
  void initState() {
    super.initState();
    Amplify.Auth.getCurrentUser().then((user) {
      setState(() {
        _user = user;
      });
    }).catchError((error) {
      print((error as AuthException).message);
    });
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalScore = 0;
    });
  }

  void _answerQuestion(int score) {
    _totalScore += score;

    setState(() {
      _questionIndex = _questionIndex + 1;
    });
    print(_questionIndex);
    if (_questionIndex < _questions.length) {
      print('We have more questions!');
    } else {
      print('No more questions!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Survey"),
        actions: [
          MaterialButton(
            onPressed: () {
              Amplify.Auth.signOut().then((_) {
                Navigator.pushReplacementNamed(context, '/');
              });
            },
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: _questionIndex < _questions.length
            ? Quiz(
          answerQuestion: _answerQuestion,
          questionIndex: _questionIndex,
          questions: _questions,
        ) //Quiz
            : Result(_totalScore, _resetQuiz, _user.username),
      ), //Padding
    );

  }

}
