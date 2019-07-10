select ZONE,AREA_DESC,ZONE_DESC,AISLE_DESC,BAY_DESC,LOCN_QTY,STD_QTY,AREA_CASE_QTY,FHW_LOCN_QTY,APC_LOCN_QTY,USED_LOCN,
USED_PECT,EMPT_LOCN,FHW_CASE_QTY,APC_CASE_QTY,CASE_QTY,USED_CASE_PECT,USED_LOCN_DSN_QTY,USED_LOCN_CASE_PECT,SEQ
from
(
    select 
        ZONE,
        AREA_DESC,
        ZONE_DESC,
        AISLE_DESC,
        BAY_DESC,
        count(distinct LOCN_BRCD) as LOCN_QTY,
        STD_QTY,
        STD_QTY * count(distinct LOCN_BRCD) as AREA_CASE_QTY,
        count(case when PROD_TYPE = '01' then 1 when PROD_TYPE='03' then 1 ELSE NULL END ) as FHW_LOCN_QTY,
        count(case when PROD_TYPE = '02' then 1 when PROD_TYPE='04' then 1 ELSE NULL END ) as APC_LOCN_QTY,
        count(case when SKU_ID is not null then 1 else null end) as USED_LOCN,
        count(case when SKU_ID is not null then 1 else null end)/count(distinct LOCN_BRCD) as USED_PECT,
        count(distinct LOCN_BRCD) - count(case when SKU_ID is not null then 1 else null end) as EMPT_LOCN,
        sum(case when PROD_TYPE = '01' then CASE_QTY when PROD_TYPE = '03' then CASE_QTY ELSE NULL END) as FHW_CASE_QTY,
        sum(case when PROD_TYPE = '02' then CASE_QTY when PROD_TYPE = '04' then CASE_QTY ELSE NULL END) as APC_CASE_QTY,
        sum (CASE_QTY) as CASE_QTY,
        sum (CASE_QTY)/(STD_QTY*count(distinct LOCN_BRCD)) as USED_CASE_PECT,
        count(case when SKU_ID is not null then 1 else null end) * STD_QTY as USED_LOCN_DSN_QTY,
        case when count(case when SKU_ID is not null then 1 else null end)=0 then 0 ELSE sum (CASE_QTY)/(count(case when SKU_ID is not null then 1 else null end)*STD_QTY) END as USED_LOCN_CASE_PECT,
        SEQ
    from 
    (

        --ZONE A FULL PALLET
        select distinct LH.ZONE,'PltRsv-APP/ACC' as AREA_DESC,'' as ZONE_DESC,'01-06,51-56' as AISLE_DESC,'1-14,51-76' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,1 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID  = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='A'
        and ((LH.AISLE >='01' and LH.AISLE <='06') or (LH.AISLE >='51' and LH.AISLE <='56'))
        and ((LH.BAY>='01' and LH.BAY <='14') or (LH.BAY>='51' and LH.BAY <='76'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE A HALF PALLET
        select distinct LH.ZONE,'HfPltRsv-APP/ACC' as AREA_DESC,'' as ZONE_DESC,'01-06,51-56' as AISLE_DESC,'15-20,77-80' as BAY_DESC,10 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,2 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='A'
        and ((LH.AISLE >='01' and LH.AISLE <='06') or (LH.AISLE >='51' and LH.AISLE <='56'))
        and ((LH.BAY>='15' and LH.BAY <='20') or (LH.BAY>='77' and LH.BAY <='80'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE B FULL PALLET
        select distinct LH.ZONE,'PltRsv-FW/HW' as AREA_DESC,'' as ZONE_DESC,'01-06, 51-60' as AISLE_DESC,'1-14,51-76' as BAY_DESC,16 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,3 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='B'
        and ((LH.AISLE >='01' and LH.AISLE <='06') or (LH.AISLE >='51' and LH.AISLE <='60'))
        and ((LH.BAY>='01' and LH.BAY <='14') or (LH.BAY>='51' and LH.BAY <='76'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE B HALF PALLET
        select distinct LH.ZONE,'HfPltRsv-FW/HW' as AREA_DESC,'' as ZONE_DESC,'01-06, 51-60' as AISLE_DESC,'15-20,77-80' as BAY_DESC,8 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,4 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='B'
        and ((LH.AISLE >='01' and LH.AISLE <='06') or (LH.AISLE >='51' and LH.AISLE <='60'))
        and ((LH.BAY>='15' and LH.BAY <='20') or (LH.BAY>='77' and LH.BAY <='80'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE C FULL PALLET
        select distinct LH.ZONE,'PltRsv-APP/ACC' as AREA_DESC,'' as ZONE_DESC,'01-11,51-61' as AISLE_DESC,'1-14,51-76' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,5 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='C'
        and ((LH.AISLE >='01' and LH.AISLE <='11') or (LH.AISLE >='51' and LH.AISLE <='61'))
        and ((LH.BAY>='01' and LH.BAY <='14') or (LH.BAY>='51' and LH.BAY <='76'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE C HALF PALLET
        select distinct LH.ZONE,'HfPltRsv-APP/ACC' as AREA_DESC,'' as ZONE_DESC,'01-11,51-61' as AISLE_DESC,'15-20,77-80' as BAY_DESC,10 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,6 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='C'
        and ((LH.AISLE >='01' and LH.AISLE <='11') or (LH.AISLE >='51' and LH.AISLE <='61'))
        and ((LH.BAY>='15' and LH.BAY <='20') or (LH.BAY>='77' and LH.BAY <='80'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE D FULL PALLET
        select distinct LH.ZONE,'PltRsv-FW/HW' as AREA_DESC,'' as ZONE_DESC,'01-11,51-61' as AISLE_DESC,'1-14,51-76' as BAY_DESC,16 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,7 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='D'
        and ((LH.AISLE >='01' and LH.AISLE <='11') or (LH.AISLE >='51' and LH.AISLE <='61'))
        and ((LH.BAY>='01' and LH.BAY <='14') or (LH.BAY>='51' and LH.BAY <='76'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE D HALF PALLET
        select distinct LH.ZONE,'HfPltRsv-FW/HW' as AREA_DESC,'' as ZONE_DESC,'01-11,51-61' as AISLE_DESC,'15-20,77-80' as BAY_DESC,8 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,8 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='D'
        and ((LH.AISLE >='01' and LH.AISLE <='11') or (LH.AISLE >='51' and LH.AISLE <='61'))
        and ((LH.BAY>='15' and LH.BAY <='20') or (LH.BAY>='77' and LH.BAY <='80'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE E Full Pallet
        select distinct LH.ZONE,'PltRsv-APP/ACC/FW/HW' as AREA_DESC,'' as ZONE_DESC,'09-13' as AISLE_DESC,'1-14,51-76' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,11 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='E'
        and ((LH.AISLE >='09' and LH.AISLE <='13'))
        and ((LH.BAY>='01' and LH.BAY <='14') or (LH.BAY>='51' and LH.BAY <='76'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE E Half Pallet
        select distinct LH.ZONE,'HfPltRsv-APP/ACC/FW/HW' as AREA_DESC,'' as ZONE_DESC,'09-13' as AISLE_DESC,'15-20,77-80' as BAY_DESC,10 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,12 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='E'
        and ((LH.AISLE >='09' and LH.AISLE <='13'))
        and ((LH.BAY>='15' and LH.BAY <='20') or (LH.BAY>='77' and LH.BAY <='80'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE E Normal NS PltRsv
        select distinct LH.ZONE,'Normal NS PltRsv' as AREA_DESC,'' as ZONE_DESC,'60(even)-61' as AISLE_DESC,'51-80' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,13 as SEQ
        from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where 
             LH.LOCN_CLASS = 'R' 
             and LH.ZONE='E' 
             and( ( LH.AISLE ='61' and LH.BAY>='51' and LH.BAY <='80')
               or ( LH.AISLE ='60' AND LH.BAY>='51' and LH.BAY <='80' and mod(lh.bay,2) = 0 ) )
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all
        
        --????
        --ZONE E Normal NS HfPltRsv
        select distinct LH.ZONE,'Normal NS HfPltRsv' as AREA_DESC,'' as ZONE_DESC,'60(even)-61' as AISLE_DESC,'51-80' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,13 as SEQ
        from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where 
             LH.LOCN_CLASS = 'R' 
             and LH.ZONE='E'
             and( ( LH.AISLE ='61' and LH.BAY>='01' and LH.BAY <='50')
               or ( LH.AISLE ='60' AND LH.BAY>='01' and LH.BAY <='50' and mod(lh.bay,2) = 0 ) )
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all
        
        --????
        ------------------------------
        --ZONE E Return PltRsv-FW/HW
        --------++++++----------------
        select distinct LH.ZONE,'Normal Return PltRsv FW/HW' as AREA_DESC,'' as ZONE_DESC,'59,60(odd),62-63' as AISLE_DESC,'51-80' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,13 as SEQ
        from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where 
             LH.LOCN_CLASS = 'R' 
             and LH.ZONE='E' 
             AND (LH.BAY>='51' and LH.BAY <='80')
             and( ( LH.AISLE ='59' )
               or ( LH.AISLE >='62' and LH.AISLE<='63')
               or ( LH.AISLE  ='60' and mod(lh.bay,2) = 1 )
                )
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all
        
        --????
        ------------------------------
        --ZONE E Return HfPltRsv-FW/HW
        --------++++++----------------
        select distinct LH.ZONE,'Normal Return HfPltRsv FW/HW' as AREA_DESC,'' as ZONE_DESC,'59,60(odd),62-63' as AISLE_DESC,'01-50' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,13 as SEQ
        from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where 
             LH.LOCN_CLASS = 'R' 
             AND LH.ZONE='E'
             AND (LH.BAY>='01' and LH.BAY <='50')
             and( ( LH.AISLE ='59' )
               or ( LH.AISLE >='62' and LH.AISLE<='63')
               or ( LH.AISLE  ='60' and mod(lh.bay,2) = 1 )
                )
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all
       
        
        
        --ZONE F Normal CsRsv-APP/ACC
        select distinct LH.ZONE,'Normal APP/ACC' as AREA_DESC,'' as ZONE_DESC,'04,05,07,08,54,55,57,58' as AISLE_DESC,'1-30,51-94' as BAY_DESC,2 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,15 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='F'
        and (LH.AISLE in ('04','05','07','08','54','55','57','58'))
        and ((LH.BAY>='01' and LH.BAY <='30') or (LH.BAY>='51' and LH.BAY <='94'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE F Normal NS
        select distinct LH.ZONE,'Normal NS' as AREA_DESC,'' as ZONE_DESC,'56' as AISLE_DESC,'51-94' as BAY_DESC,2 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,16 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='F'
        and ((LH.AISLE='56'))
        and ((LH.BAY>='51' and LH.BAY <='94'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --????ZONE F Return APP/ACC
        select distinct LH.ZONE,'Return APP/ACC' as AREA_DESC,'' as ZONE_DESC,'01-03,51-53' as AISLE_DESC,'' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,18 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and  LH.ZONE='F'
        and ((LH.AISLE >='01' and LH.AISLE <='03') or (LH.AISLE >='51' and LH.AISLE <='53'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all
        

        --ZONE F Return NS Reserve
        select distinct LH.ZONE,'Return NS Reserve' as AREA_DESC,'' as ZONE_DESC,'06' as AISLE_DESC,'Level: 03-10' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,18 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and  LH.ZONE='F'
        and  LH.AISLE='06'
        and (LH.LVL >='03' and LH.LVL <='10')
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE F Return NC Reserve 
        select distinct LH.ZONE,'Return NC Reserve' as AREA_DESC,'' as ZONE_DESC,'55' as AISLE_DESC,'93-94 Level: 04-19' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,21 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='F'
        and (LH.AISLE ='55') 
        and (LH.BAY='93' or LH.BAY='94' )
        and (LH.LVL >='04' and LH.LVL <='19')
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE G Normal FW/HW
        select distinct LH.ZONE,'Normal FW/HW' as AREA_DESC,'' as ZONE_DESC,'09-13,59-62' as AISLE_DESC,'01-30,51-94' as BAY_DESC,2 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,22 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='G'
        and ((LH.AISLE >='09' and LH.AISLE <='13') or (LH.AISLE >='59' and LH.AISLE <='62'))
        and ((LH.BAY>='01' and LH.BAY <='30') or (LH.BAY>='51' and LH.BAY <='94'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE G Return FW/HW
        select distinct LH.ZONE,'Return FW/HW' as AREA_DESC,'' as ZONE_DESC,'01-08,51-58' as AISLE_DESC,'01-08,51-58 Bay: 01-08,51-58 Level: 01-30,51-94' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,23 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='G'
        and ((LH.AISLE >='51' and LH.AISLE <='58') or (LH.AISLE >='01' and LH.AISLE <='08'))
        and ((LH.BAY   >='01' and LH.BAY   <='30') or (LH.BAY >= '51' and LH.BAY <= '94'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE G NC Reserve
        select distinct LH.ZONE,'Normal NC Reserve' as AREA_DESC,'' as ZONE_DESC,'63' as AISLE_DESC,'51-94 Level:03-10' as BAY_DESC,2 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,26 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.RESV_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID and RLH.CURR_UOM_QTY>0
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'R'
        and LH.ZONE='G'
        and (LH.AISLE ='63')
        and (LH.BAY >='51' and LH.BAY <='94')
        and (LH.LVL >='03' and LH.LVL <='10')
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --BP A
        select distinct 'Belt Pick' "ZONE",LH.ZONE "AREA_DESC",'' as ZONE_DESC,'B1,B2' as AISLE_DESC,'01-06' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,27 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.PICK_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID 
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE='A'
        and (LH.AISLE in ('B1','B2'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --BP B
        select distinct 'Belt Pick' "ZONE",LH.ZONE "AREA_DESC",'' as ZONE_DESC,'B1,B2' as AISLE_DESC,'01-06' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,28 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.PICK_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID 
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE='B'
        and (LH.AISLE in ('B1','B2'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --BP C
        select distinct 'Belt Pick' "ZONE",LH.ZONE "AREA_DESC",'' as ZONE_DESC,'B1,B2' as AISLE_DESC,'01-13' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,29 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.PICK_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID 
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE='C'
        and (LH.AISLE in ('B1','B2'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --BP D
        select distinct 'Belt Pick' "ZONE",LH.ZONE "AREA_DESC",'' as ZONE_DESC,'B1,B2' as AISLE_DESC,'01-13' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,30 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.PICK_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID 
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE='D'
        and (LH.AISLE in ('B1','B2'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --BP E
        select distinct 'Belt Pick' "ZONE",LH.ZONE "AREA_DESC",'' as ZONE_DESC,'B1,B2' as AISLE_DESC,'01-13' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,31 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.PICK_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID 
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE='E'
        and (LH.AISLE in ('B1','B2'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --BP F
        select distinct 'Belt Pick' "ZONE",LH.ZONE "AREA_DESC",'' as ZONE_DESC,'B1,B2' as AISLE_DESC,'01-13' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,32 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.PICK_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID 
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE='F'
        and (LH.AISLE in ('B1','B2'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --BP G
        select distinct 'Belt Pick' "ZONE",LH.ZONE "AREA_DESC",'' as ZONE_DESC,'B1,B2' as AISLE_DESC,'01-13' as BAY_DESC,15 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct CH.CASE_NBR ) as CASE_QTY,33 as SEQ from PWM12.LOCN_HDR LH 
        left join PWM12.PICK_LOCN_HDR RLH on LH.LOCN_ID = RLH.LOCN_ID 
        left join PWM12.CASE_HDR CH on CH.LOCN_ID = LH.LOCN_ID
        left join PWM12.CASE_DTL CD on CD.CASE_NBR = CH.CASE_NBR
        left join PWM12.ITEM_MASTER IM on IM.sku_id = CD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE='G'
        and (LH.AISLE in ('B1','B2'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        
    )t1
    group by ZONE,AREA_DESC,ZONE_DESC,AISLE_DESC,BAY_DESC,STD_QTY,SEQ
)T_Reserve
 
 
union all
        
-------------------------------------------------
--Reserve Complete
--Active Start 
-------------------------------------------------


select ZONE,AREA_DESC,ZONE_DESC,AISLE_DESC,BAY_DESC,LOCN_QTY,STD_QTY,AREA_CASE_QTY,FHW_LOCN_QTY,APC_LOCN_QTY,USED_LOCN,
     USED_PECT,EMPT_LOCN,FHW_CASE_QTY,APC_CASE_QTY,CASE_QTY,USED_CASE_PECT,USED_LOCN_DSN_QTY,USED_LOCN_CASE_PECT,SEQ 
from
(
    SELECT ZONE
        ,AREA_DESC
        ,ZONE_DESC
        ,AISLE_DESC
        ,BAY_DESC
        ,count(DISTINCT LOCN_BRCD) AS LOCN_QTY
        ,STD_QTY
        ,STD_QTY * count(DISTINCT LOCN_BRCD) AS AREA_CASE_QTY
        ,0 AS FHW_LOCN_QTY
        ,0 AS APC_LOCN_QTY
        ,count(CASE WHEN SKU_ID IS NOT NULL THEN 1 ELSE NULL END) AS USED_LOCN
        ,count(CASE WHEN SKU_ID IS NOT NULL THEN 1 ELSE NULL END) / count(DISTINCT LOCN_BRCD) AS USED_PECT
        ,count(DISTINCT LOCN_BRCD) - count(CASE WHEN SKU_ID IS NOT NULL THEN 1 ELSE NULL END) AS EMPT_LOCN
        ,0 AS FHW_CASE_QTY
        ,0 AS APC_CASE_QTY
        ,0 AS CASE_QTY
        ,0 AS USED_CASE_PECT
        ,0 AS USED_LOCN_DSN_QTY
        ,0 AS USED_LOCN_CASE_PECT
        ,SEQ
    from 
    (
    
        --ZONE F Return NC Active
        select distinct LH.ZONE,'Return NC Active' as AREA_DESC,'' as ZONE_DESC,'55' as AISLE_DESC,'93,94 Level: 01-03' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,19 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'F'
        and (LH.AISLE ='55')
        and (LH.BAY >='93' and LH.BAY <='94')
        and (LH.LVL >='01' and LH.LVL <='03')
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        
        union all 
        
        --ZONE G NC Active
        select distinct LH.ZONE,'Normal NC Active' as AREA_DESC,'' as ZONE_DESC,'63' as AISLE_DESC,'51-94 Level:01-02' as BAY_DESC,2 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,25 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'G'
        and (LH.AISLE ='63')
        and (LH.BAY >='51' and LH.BAY <='94')
        and (LH.LVL >='01' and LH.LVL <='02')        
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all
    

        --ZONE N Nomal APP/ACC
        select LH.ZONE,'Normal APP/ACC' as AREA_DESC,'' as ZONE_DESC,'10-17,19-44' as AISLE_DESC,'1-14' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,26 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'N'
        and ((AISLE >= '10' and AISLE <= '17') OR (AISLE >= '19' and AISLE <= '44'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE N Nomal Hotpic
        select LH.ZONE,'Normal Hotpic' as AREA_DESC,'' as ZONE_DESC,'18' as AISLE_DESC,'1-14' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,26 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'N'
        and ((AISLE = '18'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all


        --ZONE Q Normal FW/HW
        select distinct LH.ZONE,'Normal FW/HW' as AREA_DESC,'' as ZONE_DESC,'01-29,31-35' as AISLE_DESC,'1-14' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,27 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE  = 'Q'
        and ((AISLE >= '01' and AISLE <= '29') OR (AISLE >= '31' and AISLE <= '35'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE Q Normal Hotpic
        select distinct LH.ZONE,'Normal Hotpic' as AREA_DESC,'' as ZONE_DESC,'30' as AISLE_DESC,'1-14' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,27 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'Q'
        and ((AISLE = '30'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all


        --ZONE M Return
        select distinct LH.ZONE,'Return FW/HW' as AREA_DESC,'' as ZONE_DESC,'01-32' as AISLE_DESC,'01-32' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,28 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'M'
        and ((LH.AISLE >='01' and LH.AISLE <='32'))
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE

        union all

        select distinct LH.ZONE,'Return APP/ACC' as AREA_DESC,'' as ZONE_DESC,'' as AISLE_DESC,'' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,34 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'K'
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all
        

        select distinct LH.ZONE,'Return FW/HW' as AREA_DESC,'' as ZONE_DESC,'01-08' as AISLE_DESC,'' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,34 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'H'
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all
        
        --ZONE J Return APP/ACC
        select distinct LH.ZONE,'Return APP/ACC' as AREA_DESC,'' as ZONE_DESC,'51-58' as AISLE_DESC,'' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,35 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'J'
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all
        
        --ZONE P Normal NS
        select distinct LH.ZONE,'Normal NS' as AREA_DESC,'' as ZONE_DESC,'51-56' as AISLE_DESC,'51-56' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,36 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'P'
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE R Return
        select distinct LH.ZONE,'Return FW/HW' as AREA_DESC,'' as ZONE_DESC,'01-05' as AISLE_DESC,'01-30Aisle' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,34 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'R'
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all

        --ZONE L Return
        select distinct LH.ZONE,'Return APP/ACC' as AREA_DESC,'' as ZONE_DESC,'11-29,32(even),33-43' as AISLE_DESC,'11-29,32(even),33-43' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,30 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'L'
        and ( (LH.AISLE ='32' and mod(LH.BAY,2) = 0 )
           or (LH.AISLE >='11' and LH.AISLE <='29')
           or (LH.AISLE >='33' and LH.AISLE <='43')
            )
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
        union all
        
        --ZONE L Return NS/HV
        select distinct LH.ZONE,'Return NS/HV' as AREA_DESC,'' as ZONE_DESC,'30-31,32(odd)' as AISLE_DESC,'30,31,32(odd)' as BAY_DESC,1 as STD_QTY,
        LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE,count(distinct LH.LOCN_BRCD ) as CASE_QTY,31 as SEQ  from PWM12.LOCN_HDR LH
        left join PWM12.PICK_LOCN_HDR PLH on LH.LOCN_ID = PLH.LOCN_ID
        left join PWM12.PICK_LOCN_DTL PLD on LH.LOCN_ID = PLD.LOCN_ID
        left join PWM12.ITEM_MASTER IM on IM.SKU_ID = PLD.SKU_ID
        where LH.LOCN_CLASS = 'A'
        and LH.ZONE = 'L'
        and (  (LH.AISLE >='30' and LH.AISLE <= '31' )
            or (LH.AISLE  ='32' and mod(LH.BAY,2) = 1 ) 
            )
        group by LH.ZONE,LH.LOCN_BRCD,IM.SKU_ID,IM.PROD_TYPE
    
    )t1
    group by ZONE,AREA_DESC,ZONE_DESC,AISLE_DESC,BAY_DESC,STD_QTY,SEQ    
) T_Active    
order by ZONE, SEQ