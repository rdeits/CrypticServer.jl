import React from 'react';
import logo from './logo.svg';
import './App.css';


function ClueInput(props) {
  return (
      <form onSubmit={(evt) => {
        props.onSubmit(props.query);
        evt.preventDefault();
      }}>
        <label for="clue-input">Clue</label>
        <input id="clue-input" type="text" value={props.query.clue} onChange={evt => props.onValueChange({clue: evt.target.value, length: props.query.length, pattern: props.query.pattern})} />
        <label for="length-input">Length (optional)</label>
        <input id="length-input" type="number" value={props.query.length} onChange={evt => props.onValueChange({clue: props.query.clue, length: evt.target.value, pattern: props.query.pattern})} />
        <label for="pattern-input">Regex (optional)</label>
        <input id="pattern-input" type="text" value={props.query.pattern} onChange={evt => props.onValueChange({clue: props.query.clue, length: props.query.length, pattern: evt.target.value})} />
        <input type="submit" value="Solve" disabled={(props.query.clue === "" || props.query.clue === null) ? "disabled" : ""}/>
      </form>
  )
}

function fetch_with_params(path, params) {
  let url = path + "?params=" + encodeURIComponent(JSON.stringify(params));
  return fetch(url);

}

function Answer(props) {
  return (
    <h2>{props.answer}</h2>
  );
}

function Explanation(props) {
  return (
    <span>{props.explanation}</span>
  );
}

function Solution(props) {
  return (
    <div>
      <Answer answer={props.solution.answer} />
      <Explanation explanation={props.solution.explanation} />
    </div>
  );
}

function SampleClue(props) {
  return (
      <div>
        <span>{props.query.clue}</span>
        <form onSubmit={(evt) => {
          props.onSubmit(props.query);
          evt.preventDefault();
        }}>
          <input type="submit" value="Try" />
        </form>
      </div>
    );
}

function Results(props) {
  if (props.results === null) {
    return null;
  } else if (props.results.length == 0) {
    return <span>No results found.</span>
  } else {
    return (
      <div>
        {props.results.map((result, index) => {
          return (
            <Solution solution={result} key={`${result.answer}-${index}`} />
          );
        })}
      </div>
    );
  }
}

class CrypticInterface extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      waiting: false,
      results: null,
      solution: null,
      query: {
        clue: "",
        length: null,
        pattern: ""
      }
     };

    this.solveClue = this.solveClue.bind(this);
    this.handleResponse = this.handleResponse.bind(this);
    this.handleError = this.handleError.bind(this);
  }

  solveClue(query) {
    query.length = Math.round(Number(query.length));
    this.setState({waiting: true, results: null, query: query});
    console.log("query:", query);
    fetch_with_params("/solve", query).then(r => {
      if (r.ok) {
        r.json().then(this.handleResponse);
      } else {
        r.text().then(this.handleError);
      }
    });
  }

  handleError(err) {
    console.log(err);
  }

  handleResponse(json) {
    console.log("response:", json);
    this.setState({waiting: false, results: json});
  }

  render() {
    return (
      <div>
        <h1>Cryptic Crossword Clue Solver</h1>
        <span>
          This is a general tool for solving cryptic (or "British-style") crossword clues, written entirely in the <a href="https://julialang.org/">Julia</a> programming language. You can find the source code for the solver on Github at <a href="https://github.com/rdeits/CrypticCrosswords.jl">rdeits/CrypticCrosswords.jl</a>.
        </span>
        <SampleClue query={{clue: "Spin broken shingle", length: 7, pattern: ""}} onSubmit={this.solveClue}
        />
        <ClueInput onValueChange={query => this.setState({query: query})}
         onSubmit={this.solveClue}
         query={this.state.query}
        />
        {this.state.waiting &&
           <span>waiting</span>
        }
        <Results results={this.state.results}/>
      </div>
    );
  }
}

export default CrypticInterface;
