import React from 'react';
import ReactDOM from 'react-dom';
import rn from 'random-number';
import { Map, List, Set } from 'immutable';

export default root => {
  ReactDOM.render(<Starter />, root);
};

const rnOptions = {
  min: 1,
  max: 8,
  integer: true,
};

const generateRandomNumbers = () => {
  let used = Map();
  let list = List();
  for (let i = 0; i < 16; i++) {
    let num = rn(rnOptions);
    while (used.has(num) && used.get(num) === 2) {
      num = rn(rnOptions);
    }
    if (used.has(num)) {
      used = used.set(num, 2);
    } else {
      used = used.set(num, 1);
    }
    list = list.push(num);
  }
  return list;
};

const convertNumbersToLetters = board =>
  board.map(num => String.fromCharCode(num + 64));

const initBoard = () =>
  convertNumbersToLetters(generateRandomNumbers()).map(letter =>
    Map({ letter, show: false }),
  );

const init = () => ({
  board: initBoard(),
  prevGuess: null,
  clickCounter: 0,
  solved: Set(),
  ignoreClicks: false,
});

class Starter extends React.Component {
  constructor(props) {
    super(props);
    this.state = init();
  }

  handleReset() {
    if (this.cancelTimeout) clearTimeout(this.cancelTimeout);
    this.setState(init);
  }

  handleClick(index) {
    if (this.state.solved.contains(index) || this.state.ignoreClicks) {
      return;
    }
    this.setState(prevState => ({
      board: prevState.board.update(index, tile => tile.set('show', true)),
      clickCounter: prevState.clickCounter + 1,
    }));
    if (
      this.state.prevGuess &&
      this.state.prevGuess.get('letter') ===
        this.state.board.getIn([index, 'letter']) &&
      this.state.prevGuess.get('index') !== index
    ) {
      this.setState(prevState => ({
        prevGuess: null,
        solved: prevState.solved
          .add(index)
          .add(prevState.prevGuess.get('index')),
      }));
    } else if (
      this.state.prevGuess &&
      this.state.prevGuess.get('index') === index
    ) {
      this.setState(prevState => ({
        board: prevState.board.setIn([index, 'show'], false),
        prevGuess: null,
      }));
    } else if (this.state.prevGuess) {
      this.setState({ ignoreClicks: true });
      this.cancelTimeout = setTimeout(
        () =>
          this.setState(prevState => ({
            board: prevState.board
              .setIn([prevState.prevGuess.get('index'), 'show'], false)
              .setIn([index, 'show'], false),
            clickStatus: 'COMPLETE',
            prevGuess: null,
            ignoreClicks: false,
          })),
        500,
      );
    } else {
      this.setState(prevState => ({
        prevGuess: Map({
          index,
          letter: prevState.board.getIn([index, 'letter']),
        }),
      }));
    }
  }

  render() {
    return (
      <React.Fragment>
        <div className="tile-grid">
          {this.state.board.map((tile, index) => (
            <div
              key={index}
              className={
                this.state.solved.contains(index) ? 'tile solved' : 'tile'
              }
              onClick={() => this.handleClick(index)}
            >
              <div>{tile.get('show') && tile.get('letter')}</div>
            </div>
          ))}
        </div>
        <div className="info">
          <div>Click counter: {this.state.clickCounter}</div>
          <div>
            <button onClick={() => this.handleReset()}>Reset</button>
          </div>
          <div>{this.state.solved.size === 16 && 'YOU WIN!'}</div>
        </div>
      </React.Fragment>
    );
  }
}
