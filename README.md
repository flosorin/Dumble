# Dumble

A fun card game swift application.

## How to play

### Generalities

Each player starts the game with five cards.

Each card has a value : the number indicated for the cards with numbers, 10 for the face cards, 0 for the joker. The aces count for one.

The aim of the game is to have 9 points or less in the hand.

### Game course
            
The non-distributed cards are placed in heap on the table (cards hidden) and the first card is revealed.

The first player chooses one card to reject and can take either the revealed card or the first of the heap. The next player does the same and can either take the last rejected card or the first of the heap. The game continues like this.

When a player has 9 points or less, he can say 'Dumble', at the beginning of his turn.

If no one has the same amount of points (or less), every other players add their points to their total. If a player exceeds 100 points, he is eliminated from the game.

If someone has the same amount of points (or less), the player who said 'Dumble' adds 25 points to his total and the others add nothing.

After adding the points, cards are melted and distributed again.

### Special rules

If a player reaches 50, 75 or 100, he goes back to 25, 50 or 75. It only works if it is the first time.

If a player has more than one card of the same type (same numbers or same faces), he can reject all of them and take only one card in exchange. It is the same if he has following cards of the same color (3 or more). If the last player did that, the following player can choose which of those cards he takes.
