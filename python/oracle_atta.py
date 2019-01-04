# -*- coding: utf-8 -*-
import cx_Oracle, os

"""
// DB操作
打开连接
查询c1数据 > 存储 c1k > 转换格式 < 'a','b','c' > > c1k
查询d1数据 > 存储 d1k > 转换格式 < 'a','b','c' > > d1k
查询c数据 in (c1k) > 存储 ck > 转换格式 < 'a','b','c' > > ck
查询d数据 in (d1k) > 存储 dk > 转换格式 < 'a','b','c' > > dk
聚合数据ck, dk > 存储 cdk
查询a数据 in (cdk) > 存储 a.file
关闭连接

// uc机器操作
打开文件
读a.file > 存储
截取文件位置 
创建项目目录 
拷贝附件到项目目录
重命名附件[itemId_filename]
关闭文件

"""

'''
-- table name

select_utr_pro_atta ( select_utr_buyer ( select_utr_pro ) union all select_utr_buyer ( select_utr_pack and select_utr_pub ) ) and a.if_receive='T'

utr_pro_atta 
utr_buyer
utr_pro
utr_pack
utr_pub
'''

"""
-- 查询
select a.OBJ_PAPER_ID,a.OBJ_ID,a.ELECTRONIC_URL from utr_pro_atta a where a.obj_id in(
       -- 查询
       select b.buyer_id from utr_buyer b where b.pro_id in (
              -- 查询
              select p.pro_id from utr_pro p where p.pack_id is null and p.sys_domain='QZ'
              and p.pub_start_time between '2018-12-01' and  '2018-12-31')
       -- 两个select的查询结果集合并起来
       union all
       -- 查询
       select b.buyer_id from utr_buyer b where b.pack_id in (
              -- 查询
              select pp.pack_id from utr_pack pp,utr_pub pb where pb.pro_id=pp.pack_id and
              pb.pub_start_time between '2018-12-01' and  '2018-12-31' and pp.create_org_name='泉州市产权交易中心')
)
-- 过滤出有上传记录的数据 
and a.if_receive='T'

"""

os.environ["NLS_LANG"] = "AMERICAN_AMERICA.ZHS16GBK"

def oracle_setting(sql):
    """
    连接数据库，获取游标，执行sql，获取执行结果，转换元组，返回结果
    """
    # DB_CON = (cx_Oracle.connect("%s/%s@%s:%s/%s") % (oracle_user, oracle_pass, oracle_host, oracle_port, oracle_sid))
    DB_CON = cx_Oracle.connect('qyy_atta/qyy_atta@192.168.9.118:1521/orcl')
    DB_CUR = DB_CON.cursor()
    DB_CUR.execute(sql)
    DB_SELECT = DB_CUR.fetchall()
    # 查看本地编码格式的值
    # print(DB_CON.encoding)
    # print(DB_CON.nencoding)
    tup = ()
    for x in DB_SELECT:
        tup = tup + x
    # print(len(tup))
    if len(tup) == 1:
        tup1 = ('null',)
        tup = tup + tup1
        message = tup
        return message
    message = tup
    return message
    # 关闭游标，连接
    DB_CUR.close()
    DB_CON.close()
def sql1 ():
    DB_SQL1 = "select p.pro_id from utr_pro p " \
              "where p.pack_id is null and p.sys_domain='QZ' " \
              "and p.pub_start_time between '2018-12-01' " \
              "and  '2018-12-31'"
    a1 = oracle_setting(DB_SQL1)
    global a1_str
    a1_str = str(a1)
    return a1

def sql2 ():
    DB_SQL2 = "select pp.pack_id from utr_pack pp,utr_pub pb " \
              "where pb.pro_id=pp.pack_id " \
              "and pb.pub_start_time between '2018-12-01' " \
              "and  '2018-12-31' " \
              "and pp.create_org_name='泉州市产权交易中心'"
    a2 = oracle_setting(DB_SQL2)
    global a2_str
    a2_str = str(a2)
    return a2

def sql3 ():
    sql1()
    DB_SQL3 = "select b.buyer_id from utr_buyer b where b.pro_id in %s" % a1_str
    global a3
    a3 = oracle_setting(DB_SQL3)
    return a3

def sql4 ():
    sql2()
    DB_SQL4 = "select b.buyer_id from utr_buyer b where b.pack_id in %s" % a2_str
    global a4
    a4 = oracle_setting(DB_SQL4)
    return a4

def sql5 ():
    sql3()
    sql4()
    a34 = a3 + a4
    a34_str = str(a34)
    # DB_SQL5 = "select a.OBJ_PAPER_ID,a.OBJ_ID,a.ELECTRONIC_URL from utr_pro_atta a " \
    #           "where a.obj_id in %s and a.if_receive='T'" % a34_str
    # 获取上传附件的url信息
    DB_SQL5 = "select a.ELECTRONIC_URL from utr_pro_atta a where a.obj_id in %s and a.if_receive='T'" % a34_str
    a5 = oracle_setting(DB_SQL5)
    print(a5)
    for tu in a5:
        # print(type(tu), tu)
        return tu

def oracle_file ():
    outfile = "C:\ooracle_output.txt"
    os.open(outfile, os.O_CREAT | os.O_RANDOM)
    file.open(outfile)

def oracle_select ():
    sql5()

if __name__ == '__main__':
    oracle_select()
    # pass

