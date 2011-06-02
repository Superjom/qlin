from libc.stdio cimport fopen,fclose,fwrite,FILE,fread
from libc.stdlib cimport malloc,free

DEF STEP=20

cdef struct HI: 
    int left    #左侧范围
    int right   #右侧范围


#################### init_hashIndex  from  Thesaurus.pyx  #################



cdef class init_hashIndex:

    '''
    init he hash index
    '''

    #define the hash index 

    cdef HI hi[STEP]
    cdef:
        #hash的左边界
        double left
        #hash的右边界
        double right

    def __cinit__(self,char *ph,char *wide_ph):
        '''
        init
        '''
        #取得hash边界
        self.get_wide(wide_ph)

        cdef FILE *fp=<FILE *>fopen(ph,"rb")
        fread(self.hi,sizeof(HI),STEP,fp)
        fclose(fp)

    def show(self):

        '''
        显示
        '''

        cdef:
            int i
        for i in range(STEP):
            print self.hi[i].left
            print self.hi[i].right
            print '-'*50

    cdef void get_wide(self,char *ph):

        '''
        取得hash的左右边界
        '''

        f=open(ph)
        c=f.read()
        f.close()
        self.left = float(c.split()[0])
        self.right = float(c.split()[1])

    def pos(self,long hashvalue):

        '''
        pos the word by hashvalue 
        if the word is beyond hash return -1
        else return the pos
       '''

        cdef int cur=-1
        
        cdef double step=<double>( (self.right-self.left)/STEP )
        
        return <int>int((hashvalue-self.left)/step)



####################################################################


#定义 hashIndex 结构
cdef struct HI: #hashIndex 结构
    int left    #左侧范围
    int right   #右侧范围
    

cdef class Init_thesaurus:

    '''
    初始化词库
    '''

    #使用动态分配内存方式  
    #分配词库内存空间
    cdef char **word_list
    #一级hash 参考表 初始化
    cdef init_hashIndex hashIndex
    #词库长度 由 delloc 调用
    cdef int length

    def __cinit__(self,char *ph):

        '''
        传入词库地址
        初始化词库
        '''

        #一级hash 参考表 初始化
        self.hashIndex = init_hashIndex("store/index_hash.b","store/word_wide.txt")

        cdef:
            int i
            int l

        f=open(ph)
        words=f.read().split()
        f.close()

        #词的数量 
        self.length=len(words)

        #开始分配词库内存空间
        cdef char  **li=<char **>malloc( sizeof(char *) * self.length )

        print '初始化词库 分配了',sizeof(li)/sizeof(char *),'块内存'

        if li!=NULL:
            print 'the li is successful'
            self.word_list=li

        else:
            print 'the word li is failed'
        

        #开始对每个词分配内存 
        #并且分配内存

        for i,w in enumerate(words):

            #self.word_list[i]=<char *>malloc( sizeof(char) * len(w) )
            #print 'the word is '

            #print w
            self.word_list[i]=w

            #print self.word_list[i]

    def __dealloc__(self):

        '''
        释放c内存空间
        '''

        print 'begin to delete all the C spaces'

        cdef char* point
        cdef int i=0

        #释放每一个词的空间
        '''for i in range(self.length):
            free(self.word_list[i])'''

        #释放整个词库 pointer 的空间
        free(self.word_list)


    cdef double v(self,data):

        '''
        将元素比较的属性取出
        '''

        return hash(data)


    def show(self):

        '''
        显示
        '''
        cdef:
            int i

        print 'the length is',self.length
        for i in range(self.length):
            print i,self.word_list[i]


    def find(self,data):

        '''
        具体查取值 
        若存在 返回位置 
        若不存在 返回   0
        '''

        '''print 'in wordbar now'
        print '> begin to find',data
        print 'length of wordbar', self.length
        '''
        #需要测试 
        #print 'want to find ',hash(data),data
        cdef:
            int l
            int fir
            int mid
            int end
            int pos
            HI cur  #范围

        #print '初始化数据ok'

        dv=self.v(data)     #传入词的hash

        pos=self.hashIndex.pos( dv )

        #print '开始 pos',pos

        if pos!=-1 and pos<STEP:
            print '开始>cur=self.hashIndex.hi[pos]'
            cur=self.hashIndex.hi[pos]
            print 'cur< OK '

        else:
            print "the word is not in wordbar or pos wrong"
            return False

        #取得 hash 的一级推荐范围
        fir=cur.left
        end=cur.right
        mid=fir

        #print '词库: fir,end,mid',fir,end,mid

        while fir<end:

            #print 'in wordbar while'
            #print 'dv',dv

            mid=(fir+ end)/2
            #print 'mid',mid
            '''
            print 'self.word_list[mid]'
            print self.word_list[mid]

            print 'dv self.v(self.word_list[mid])'
            print dv,self.v(self.word_list[mid])

            print '-'*50
            '''



            if ( dv > self.v(self.word_list[mid]) ):
                fir = mid + 1
                #print '1 if fir',fir

            elif  dv < self.v(self.word_list[mid]) :
                end = mid - 1
                #print '1 elif end',end

            else:
                break

        if fir == end:
            
            #print 'fir==end'

            if self.v(self.word_list[fir]) > dv:
                return 0 

            elif self.v(self.word_list[fir]) < dv:
                return 0

            else:
                #print 'return fir,mid,end',fir,mid,end
                #print '查得 wordid',end
                return end#需要测试
                
        elif fir>end:
            return 0

        else:
            #print '1return fir,mid,end',fir,mid,end
            #print '查得 wordid',mid
            return mid#需要测试



