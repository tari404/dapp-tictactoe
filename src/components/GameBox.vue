<template>
  <div class="game-box" :class="{
    'game-box-start': !data.result && !waiting,
    'game-box-active': !data.result && ownRound && !waiting
  }">
    <p class="game-box-id">
      游戏ID：{{data.id}}
      <span>{{offensive ? '先手' : '后手'}}</span>
    </p>
    <div>
      <div class="game-box-wait" v-if="waiting">
        等待玩家中...
      </div>
      <ul class="game-box-info" v-else>
        <li>对手：{{opponent.substr(0, 6)}}...</li>
        <li><br></li>
        <li v-if="data.result">
          <span>游戏结束：</span>
          <span>{{result}}</span>
        </li>
        <li v-else>
          <span>{{ownRound ? '我方' : '对方'}}回合</span>
        </li>
      </ul>
      <div class="game-box-map">
        <span v-for="i in 9" :key="i" :class="{
          'game-box-o': board[i - 1] === '1',
          'game-box-x': board[i - 1] === '2'
        }" />
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'GameBox',
  props: ['data'],
  computed: {
    ...mapGetters({
      address: 'web3/address'
    }),
    board () {
      return this.data.board
    },
    waiting () {
      return this.data.p2 === '0x0000000000000000000000000000000000000000'
    },
    offensive () {
      return this.data.p1 === this.address
    },
    ownRound () {
      const round = this.board.reduce((sum, value) => {
        if (value === '1') {
          return sum + 1
        } else if (value === '2') {
          return sum - 1
        }
        return sum
      }, 1)
      return round === 2 ^ this.offensive
    },
    opponent () {
      if (this.offensive) {
        return this.data.p2
      } else {
        return this.data.p1
      }
    },
    result () {
      switch (this.data.result) {
        case 1:
          return this.offensive ? '胜利' : '失败'
        case 2:
          return this.offensive ? '失败' : '胜利'
        default:
          return '平局'
      }
    }
  }
}
</script>

<style lang="stylus" scoped>
.game-box
  padding 6px
  border solid 1px #ddd
  border-radius 5px
  >div
    display flex
.game-box-start
  border-color #0d85da
.game-box-active
  background-color #f4fbff
  .game-box-map
    background-color #80bdea
.game-box-id
  font-size 14px
  flex 0 0 100%
  margin 0 0 6px 0
  span
    float right
.game-box-wait
  font-size 12px
  line-height 64px
  padding 2px 0
  flex 1 1 auto
.game-box-info
  font-size 12px
  line-height 20px
  padding 2px 0
  flex 1 1 auto
  li
    margin 2px
    overflow hidden
.game-box-map
  width 64px
  padding 4px
  border-radius 4px
  background-color #eee
  display grid
  grid-template-columns repeat(3, 20px)
  grid-gap 2px
  span
    display block
    background-color #fff
    height 20px
    position relative
    &:after
      width 20px
      height 20px
      position absolute
      top 0
      left 0
      text-align center
      font-size 14px
      line-height 22px
      font-weight bold
.game-box-o:after
  content 'O'
  color #ca0000
.game-box-x:after
  content 'X'
  color #0000ca
</style>
