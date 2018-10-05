import React from 'react';
import ReactDOM from 'react-dom';
import socket from './socket';

export default root => {
  ReactDOM.render(<Starter />, root);
};

const init = () => ({
  prevGuess: null,
  clickCounter: 0,
  solved: {},
  incorrectGuess: null,
});

class Starter extends React.Component {
  constructor(props) {
    super(props);
    this.range = new Array(16).fill(null);
    this.state = init();
  }

  componentDidMount() {
    this.channel = socket.channel(`room:${window.id}`, {});
    this.channel.join().receive('ok', serverState => {
      serverState.incorrectGuess = null;
      serverState.prevGuess = null;
      this.setState(serverState);
    });
  }

  handleReset() {
    if (this.cancelTimeout) {
      clearTimeout(this.cancelTimeout);
      this.cancelTimeout = null;
    }
    this.channel.push('reset').receive('ok', newState => {
      this.setState(newState);
    });
  }

  handleSocketClick({ guessIndex }) {
    if (this.cancelTimeout) {
      clearTimeout(this.cancelTimeout);
      this.cancelTimeout = null;
      this.setState({ incorrectGuess: null });
    }
    if (this.state.solved[guessIndex]) return;
    if (this.state.prevGuess && this.state.prevGuess.index === guessIndex)
      return;
    this.channel.push('guess', { guessIndex }).receive('ok', newState => {
      if (newState.incorrectGuess) {
        this.cancelTimeout = setTimeout(
          () => this.setState({ incorrectGuess: null }),
          750,
        );
      }
      this.setState(newState);
    });
  }

  tile(index) {
    if (this.state.solved[index])
      return String.fromCharCode(this.state.solved[index] + 64);
    if (this.state.incorrectGuess && this.state.incorrectGuess[index])
      return String.fromCharCode(this.state.incorrectGuess[index] + 64);
    if (this.state.prevGuess && this.state.prevGuess.index === index)
      return String.fromCharCode(this.state.prevGuess.value + 64);
    return null;
  }

  render() {
    return (
      <React.Fragment>
        <div className="tile-grid">
          {this.range.map((value, index) => (
            <div
              className={this.state.solved[index] ? 'tile solved' : 'tile'}
              key={Math.random()}
              onClick={() => this.handleSocketClick({ guessIndex: index })}
            >
              {this.tile(index)}
            </div>
          ))}
        </div>
        <div className="info">
          <div>Click counter: {this.state.clickCounter}</div>
          <div>
            {Object.keys(this.state.solved).length === 16 && 'YOU WIN!'}
          </div>
          <button onClick={() => this.handleReset()}>reset game</button>
        </div>
      </React.Fragment>
    );
  }
}
