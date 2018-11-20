<template>
  <div id="app">
    <nav>
      <div class="main-width">
        <h1>链上井字棋小游戏</h1>
        <div class="game-user">
          使用<span :class="{'focus': userIndex === 0}" @click="toggleUser(0)">用户1</span>
          <span :class="{'focus': userIndex === 1}" @click="toggleUser(1)">用户2</span>
          <span :class="{'focus': userIndex === 2}" @click="toggleUser(2)">用户3</span>
          <span :class="{'focus': userIndex === 3}" @click="toggleUser(3)">用户4</span>账号
        </div>
      </div>
    </nav>
    <section>
      <div class="main-width game-account">
        账户地址：{{address}}
      </div>
    </section>
    <section>
      <div class="main-width">
        <span class="game-network-name">合约名称：{{contractName}}</span>
        <span class="game-network-state" :style="{
          'color': networkState === 1 ? '#2fa4d9' : '#d80315'
        }">{{networkNotice}}</span>
      </div>
    </section>
    <section v-if="!beforeRefresh">
      <game-list @focus="onFocusGame" />
    </section>
    <notice />
    <copyboard />
    <game v-if="focusGame" :data="focusGame" @close="onBlurGame" />
  </div>
</template>

<script>
import { mapState, mapGetters, mapActions } from 'vuex'
import Notice from '@/components/Notice'
import Copyboard from '@/components/Copyboard'
import GameList from '@/components/GameList'
import Game from '@/components/Game'

export default {
  name: 'App',
  data () {
    return {
      beforeRefresh: false,
      userIndex: 0,

      focusGame: null
    }
  },
  computed: {
    ...mapState({
      contractName: state => state.web3.name,
      networkState: state => state.web3.state
    }),
    ...mapGetters({
      address: 'web3/address'
    }),
    networkNotice () {
      switch (this.networkState) {
        case 1:
          return '网络连接正常'
        case 2:
          return '网络连接异常'
        default:
          return ''
      }
    }
  },
  created () {
    this.checkNetwork()
    this.queryGameCount()
  },
  methods: {
    ...mapActions({
      checkNetwork: 'web3/checkNetwork',
      queryGameCount: 'web3/queryGameCount',
      updateUser: 'web3/updateUser'
    }),
    toggleUser (index) {
      if (this.index === index) {
        return
      }
      this.beforeRefresh = true
      this.$nextTick(() => {
        this.beforeRefresh = false
      })
      this.userIndex = index
      this.updateUser(index)
    },
    onFocusGame (game) {
      this.focusGame = game
    },
    onBlurGame () {
      this.focusGame = null
    }
  },
  components: {
    Notice,
    Copyboard,
    GameList,
    Game
  }
}
</script>

<style lang="stylus">
body
  margin 0
  background-color #f0f4f8
  font-family Avenir,Helvetica,Arial,sans-serif
  -webkit-text-size-adjust none
body::-webkit-scrollbar
  display none
  width 0
  height 0
  opacity 0
a
  color inherit
ul
  margin 0
  padding 0
li
  list-style none

.main-width
  margin auto
  flex 0 1 800px
  min-width 480px
  box-sizing border-box

.game-blank
  line-height 20px

nav
  height 80px
  padding 0 10px
  display flex
  background-color #fff
  box-shadow 0 2px 4px #0001
  h1
    margin 0
    display inline
    font-size 20px
    font-weight 400
    line-height 40px
  .game-user
    margin 5px 0
    float right
    line-height 20px
    color #666
    span
      display inline-block
      padding 4px
      margin 0 2px
      border dashed 1px #ddd
      border-radius 3px
      cursor pointer
    .focus
      background-color #0d85da
      border-color #0d85da
      color #fff
section
  margin 20px 10px
  display flex

label
  display block
  line-height 40px
  width 90px
  height 40px
input
  font-family inherit
  font-size inherit
  box-sizing border-box
  border-radius 3px
  border 1px solid #ddd
  font-size 16px
  outline none
  height 40px
  margin 0
  padding 0 9px

.game-account
  padding 10px 20px
  border-radius 5px
  border dashed 1px #aaa
  color #666

.game-network-name
  font-size 16px
  line-height 24px
.game-network-state
  float right
  font-size 14px
  line-height 24px

.game-content
  background-color #fff
  border-radius 5px
  background-color #fff
  padding 20px
  box-shadow 0 2px 4px #0001
  margin-bototm 100px
.game-content-title
  font-size 18px
  line-height 30px
  position relative
  &:before
    content ''
    position absolute
    top 8px
    left -22px
    width 0
    height 0
    border-left solid 6px #0d85da
    border-top solid 6px transparent
    border-bottom solid 6px transparent

.game-notice
  margin-top 4px
  font-size 12px
  color #666

.game-button
  border-radius 3px
  color #fff
  width 150px
  height 40px
  text-align center
  line-height 40px
  background-color #ccc
  transition background-color .4s
  position relative
  div
    border-radius 3px
    transition background-color .4s,transform .4s
    background-color #bbb
  .need-to-pay:after
    content ''
    position absolute
    top 5px
    right 8px
    width 26px
    height 26px
    background-image url(./assets/pay.svg)
    background-size contain
    background-position center
    background-repeat no-repeat
.game-button-active
  background-color #0072c1
  div
    background-color #0d85da
    cursor pointer
    transform translateY(-6px)
    &:hover
      transform translateY(-3px)
</style>
