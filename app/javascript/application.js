import React from 'react';
import { createRoot } from 'react-dom/client';
import Crossword from 'react-crossword/javascripts/crosswords/crossword';
import { createSubscription } from 'subscription';

const crosswordElement = document.getElementsByClassName('js-crossword')[0];

if (crosswordElement) {
  const { crossword, crosswordIdentifier, room } = crosswordElement.dataset;
  const crosswordData = JSON.parse(crossword);

  const crosswordRef = React.createRef();

  const onReceiveMove = (move) => {
    crosswordRef.current.setCellValue(move.x, move.y, move.value, false);
  };

  const onReplayMove = (move) => {
    if (crosswordRef.current.getCellValue(move.x, move.y) === move.previousValue) {
      crosswordRef.current.setCellValue(move.x, move.y, move.value);
    }
  };

  const subscription = createSubscription(
    crosswordIdentifier,
    room,
    onReceiveMove,
    onReplayMove,
    (initialState) => {
      const root = createRoot(crosswordElement);
      root.render(
        <Crossword
          ref={crosswordRef}
          data={crosswordData}
          loadGrid={() => {}}
          saveGrid={() => {}}
          onMove={(move) => { subscription.move(move); }}
        />
      );

      // This may need to be delayed slightly to avoid race conditions
      setTimeout(() => {
        crosswordRef.current.updateGrid(initialState);
      }, 0);
    }
  );
}

