<template>
  <div id="game-mask">
    <div class="game-main" :class="{
      'game-main-active': myTurn
    }">
      <div class="game-content-title">
        游戏ID {{data.id}}
        <span class="close" @click="close">关闭</span>
      </div>
      <ul class="game-main-info">
        <li>
          <span class="key" :class="{ 'winner': data.result === 1 }">先手</span>
          <span class="value">{{data.p1}}</span>
        </li>
        <li>
          <span class="key" :class="{ 'winner': data.result === 2 }">后手</span>
          <span class="value">{{data.p2}}</span>
        </li>
      </ul>
      <div class="game-main-map">
        <span v-for="i in 9" :key="i" :class="{
          'game-grid-active': myTurn && board[i - 1] === '0',
          'game-grid-selected-o': selectGrid === i && data.p1 === address,
          'game-grid-selected-x': selectGrid === i && data.p2 === address,
          'game-main-o': board[i - 1] === '1',
          'game-main-x': board[i - 1] === '2'
        }" @click="clickGrid(i)" />
      </div>
      <div v-if="myTurn">
        <div class="game-notice">当前是你的回合，可以选择下一步棋的位置</div>
        <div class="game-button" :class="{ 'game-button-active': selectGrid && !invoking }">
          <div class="need-to-pay" @click="submitNextStep">{{ invoking ? '处理中...' : '确认' }}</div>
        </div>
      </div>
      <div class="game-notice" v-else-if="!data.result">
        玩家{{currentTurn}}的回合
      </div>
      <div class="game-notice" v-else>
        游戏已结束
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'Game',
  props: ['data'],
  data () {
    return {
      itvl: 0,

      selectGrid: 0,
      invoking: false
    }
  },
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
    currentTurn () {
      const round = this.board.reduce((sum, value) => {
        if (value === '1') {
          return sum + 1
        } else if (value === '2') {
          return sum - 1
        }
        return sum
      }, 1)
      return round === 2 ? this.data.p2 : this.data.p1
    },
    myTurn () {
      return !this.data.result && this.currentTurn === this.address && !this.waiting
    }
  },
  mounted () {
    this.itvl = setInterval(() => {
      this.data.update()
    }, 2000)
  },
  methods: {
    ...mapActions({
      notice: 'notice',
      nextStep: 'web3/nextStep'
    }),
    close () {
      this.$emit('close')
    },
    submitNextStep () {
      this.invoking = true
      const gameID = this.data.id
      const index = this.selectGrid - 1
      this.nextStep({ gameID, index }).then(res => {
        this.invoking = false
        if (res.status) {
          this.selectGrid = 0
          this.notice(['log', '操作成功', 10000])
          this.data.update()
        } else if (/reverted by the EVM/.test(res.message)) {
          this.notice(['error', `操作失败 请尝试刷新页面并重试`, 10000])
        } else {
          this.notice(['error', `操作失败 可能是由于网络等原因导致的`, 10000])
        }
      })
    },
    clickGrid (index) {
      if (!this.myTurn || this.board[index - 1] !== '0') {
        return
      }
      this.selectGrid = index
    }
  },
  beforeDestroy () {
    clearInterval(this.itvl)
  }
}
</script>

<style lang="stylus" scoped>
#game-mask
  position fixed
  top 0
  left 0
  background-color #0008
  width 100%
  height 100%
  display flex
  align-items center
  z-index 10
.game-main
  margin auto
  padding 20px
  background-color #fff
  border-radius 10px
  .close
    float right
    cursor pointer
    font-size 16px
.game-main-active
  .game-main-map
    background-color #80bdea
.game-main-info
  margin-top 10px
  li
    display flex
    line-height 24px
  .key
    flex 0 0 60px
  .value
    flex 1 1 auto
    font-size 12px
    text-align right
  .winner:after
    content '🏆'
    float right

.game-main-map
  margin 10px auto 
  width 320px
  padding 20px
  border-radius 10px
  background-color #eee
  display grid
  grid-template-columns repeat(3, 100px)
  grid-gap 10px
  span
    display block
    background-color #fff
    height 100px
    position relative
    &:after
      width 100px
      height 100px
      position absolute
      top 0
      left 0
      font-size 80px
      line-height 110px
      text-align center
      font-weight bold
.game-grid-active
  cursor pointer
  transform-origin bottom
  transition transform .4s
  &:hover
    transform scaleY(.95)
.game-grid-selected-o:after
  content 'O'
  color #ca0000
  opacity .4
.game-grid-selected-x:after
  content 'X'
  color #0000ca
  opacity .4
.game-main-o:after
  content 'O'
  color #ca0000
.game-main-x:after
  content 'X'
  color #0000ca

.game-button
  margin-top 10px
</style>
